extends Node

const tetromino_scene = preload("res://scenes/tetromino.tscn")
const pentomino_scene = preload("res://scenes/pentomino.tscn")
const tile_scene = preload("res://scenes/tile.tscn")
const pentris_tile_scene = preload("res://scenes/pentris_tile.tscn")

@onready var board_area: Node2D = $BoardAndContainers/BoardArea
@onready var generator: SevenBagGenerator = $BagGenerator
@onready var board_and_containers: CanvasLayer = $BoardAndContainers
@onready var lines_label: Label = $Hud/MarginContainer/VBoxContainer/LinesLabel
@onready var score_label: Label = $Hud/MarginContainer/VBoxContainer/ScoreLabel
@onready var high_score_label: Label = $Hud/MarginContainer/VBoxContainer/HighScoreLabel
@onready var hud: CanvasLayer = $Hud
@onready var held_pieces_container: GridContainer = %HeldPiecesContainer
@onready var next_piece_container: TextureRect = %NextPieceContainer

enum {
	ACTIVE,
	NEXT,
	HELD,
	GHOST
}

var board : Array = []

var lines_cleared : int = 0
var score : int = 0


var next_piece : Piece
var current_piece : Piece
var held_pieces : Array[Piece] = []

var next_piece_position : Vector2

var elapsed_time : float = 0
var time_to_scramble : int

var just_released : bool = false
var paused : bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_I:
			$Hud/TouchControls.visible = !$Hud/TouchControls.visible

func _ready() -> void:
	Globals.TICK_DURATION = 1.0
	Globals.load_score()
	SceneChanger.scene_changed.connect(_on_scene_changed)
	if Globals.hardcore_mode:
		Globals.spawn_ghost_piece = false
	create_board()
	
	for i in range(Globals.ROWS[Globals.game_mode] - 1, Globals.ROWS[Globals.game_mode] - Globals.garbage_rows - 1, -1):
		fill_row_with_garbage(i)
		
	lines_label.text = "Lines: %d" % lines_cleared
	score_label.text = "Score: %d" % score
	high_score_label.text = "High Score: %d" % Globals.high_score[Globals.game_mode]
	time_to_scramble = randi_range(30, 40)
	hud.game_over_shown.connect(_on_game_over_shown)

func _process(delta: float) -> void:
	if Globals.hardcore_mode:
		elapsed_time += delta
		if elapsed_time >= time_to_scramble:
			scramble_random_row()
			elapsed_time = 0
			time_to_scramble = randi_range(30, 40)

	if Input.is_action_just_pressed("quit"):
		if is_instance_valid(current_piece):
			current_piece.set_physics_process(false)
			current_piece.set_process_input(false)
		$GameOverTimer.stop()
		SceneChanger.change_scene("res://scenes/title_screen.tscn")
		
	elif Input.is_action_just_pressed("toggle_ghost"):
		if Globals.hardcore_mode:
			return
		Globals.spawn_ghost_piece = !Globals.spawn_ghost_piece
		if Globals.spawn_ghost_piece:
			spawn_piece(true, current_piece)
		else:
			current_piece.ghost_piece.queue_free()

	elif Input.is_action_just_pressed("hold"):
		if !current_piece:
			return
		if held_pieces.size() < Globals.max_held_pieces and not current_piece.was_held:
			hold_piece()
			
	elif Input.is_action_just_pressed("release"):
		if held_pieces.size() > 0 and not just_released:
			release_first_held_piece()

	elif Input.is_action_just_pressed("pause"):
		paused = !paused
		get_tree().paused = paused
		toggle_board()

func spawn_piece(is_ghost : bool = false, add_ghost_to : Piece = null):
	if !is_ghost:
		if !next_piece:
			var piece : Piece
			if Globals.game_mode == Globals.GameMode.TETRIS:
				piece = tetromino_scene.instantiate() as Piece
			else:
				piece = pentomino_scene.instantiate() as Piece
			piece.piece_type = generator.get_piece()
			piece.board = board
			piece.piece_locked.connect(_on_piece_locked)
			piece.board_entered.connect(_on_piece_board_entered)
			piece.status = ACTIVE
			board_area.add_child(piece)
		else:
			next_piece.set_status(ACTIVE)
	
		if Globals.game_mode == Globals.GameMode.TETRIS:
			next_piece = tetromino_scene.instantiate() as Piece
		else:
			next_piece = pentomino_scene.instantiate() as Piece

		next_piece.piece_type = generator.get_piece()
		next_piece.board = board
		next_piece.piece_locked.connect(_on_piece_locked)
		next_piece.board_entered.connect(_on_piece_board_entered)
		next_piece.status = NEXT
		board_area.add_child(next_piece)
		next_piece.global_position = set_next_piece_position(next_piece)
		
	else:
		var ghost_piece : Piece
		if Globals.game_mode == Globals.GameMode.TETRIS:
			ghost_piece = tetromino_scene.instantiate() as Piece
		else:
			ghost_piece = pentomino_scene.instantiate() as Piece
			
		ghost_piece.is_next_piece = false
		ghost_piece.piece_type = add_ghost_to.piece_type
		ghost_piece.board = board
		add_ghost_to.ghost_piece = ghost_piece
		ghost_piece.current_coords = add_ghost_to.current_coords
		ghost_piece.position = add_ghost_to.position
		ghost_piece.status = GHOST
		board_area.add_child(ghost_piece)	

func hold_piece():
	current_piece.set_status(HELD)
	current_piece.ghost_piece.queue_free()
	current_piece.apply_rotation(0)
	var tw : Tween = create_tween()
	var tw_2 : Tween = create_tween()
	tw.finished.connect(_on_piece_held)	
	tw.tween_property(current_piece, "global_position", set_held_piece_target_position(current_piece, held_pieces.size()), 0.2)
	tw_2.tween_property(current_piece, "scale", Vector2.ONE * 1.5, 0.1)
	tw_2.tween_property(current_piece, "scale", Vector2.ONE * 0.5, 0.1)
	held_pieces.append(current_piece)
		
func release_first_held_piece():
	just_released = true
	var released_piece : Piece = held_pieces.pop_front()
	var tw : Tween = create_tween()
	var tw_2 : Tween = create_tween()
	var target_position : Vector2 = set_next_piece_position(released_piece)
	
	tw.finished.connect(_on_piece_released.bind(released_piece))
	tw.set_parallel()
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(released_piece, "global_position", target_position, 0.1)
	tw.tween_property(next_piece, "modulate:a", 0.0, 0.1)
	tw_2.tween_property(released_piece, "scale", Vector2.ONE * 1.5, 0.05)
	tw_2.tween_property(released_piece, "scale", Vector2.ONE, 0.05)
	
func set_next_piece_position(piece : Piece) -> Vector2:
	var target_position : Vector2 = next_piece_container.global_position + next_piece_container.size * 0.5
	target_position -= get_position_offset(piece)

	return target_position
	
func set_held_piece_target_position(piece : Piece, piece_count : int) -> Vector2:
	var target_position : Vector2
	var target_slot = held_pieces_container.get_child(piece_count)
	target_position = target_slot.global_position + target_slot.size * 0.5
	target_position -= get_position_offset(piece) * 0.5
	return target_position

func get_position_offset(piece : Piece) -> Vector2:
	var offset : Vector2
	if piece is Pentomino:
		if [Globals.Pentomino.Z, Globals.Pentomino.Z2, Globals.Pentomino.F, Globals.Pentomino.F2, Globals.Pentomino.T,Globals.Pentomino.V, Globals.Pentomino.W, Globals.Pentomino.X].has(piece.piece_type):
			offset = Vector2.ONE * Globals.CELL_SIZE[Globals.GameMode.PENTRIS] * 1.5
		elif [Globals.Pentomino.P, Globals.Pentomino.B].has(piece.piece_type):
			offset = Vector2(Globals.CELL_SIZE[Globals.GameMode.PENTRIS] * 1.5, Globals.CELL_SIZE[Globals.GameMode.PENTRIS] * 2)
		elif [Globals.Pentomino.U].has(piece.piece_type):
			offset = Vector2(Globals.CELL_SIZE[Globals.GameMode.PENTRIS] * 1.5, Globals.CELL_SIZE[Globals.GameMode.PENTRIS])
		elif [Globals.Pentomino.N, Globals.Pentomino.Y, Globals.Pentomino.Y2, Globals.Pentomino.S, Globals.Pentomino.N, Globals.Pentomino.J, Globals.Pentomino.L].has(piece.piece_type):
			offset = Vector2(Globals.CELL_SIZE[Globals.GameMode.PENTRIS] * 2, Globals.CELL_SIZE[Globals.GameMode.PENTRIS] * 3)
		else:
			offset = Vector2.ONE * Globals.CELL_SIZE[Globals.GameMode.PENTRIS] * 2.5
	
	elif piece is Tetromino:
		if piece.piece_type == Globals.Tetromino.I:
			offset = Vector2(Globals.CELL_SIZE[Globals.GameMode.TETRIS] * 2, Globals.CELL_SIZE[Globals.GameMode.TETRIS] * 1.5)
		elif piece.piece_type == Globals.Tetromino.O:
			offset = Vector2.ONE * Globals.CELL_SIZE[Globals.GameMode.TETRIS]
		else:
			offset = Vector2(Globals.CELL_SIZE[Globals.GameMode.TETRIS] * 1.5, Globals.CELL_SIZE[Globals.GameMode.TETRIS])
		
	return offset
	
func reposition_held_pieces():
	for i in held_pieces.size():
		var piece : Piece = held_pieces[i]
		var tw : Tween = create_tween()
		tw.set_ease(Tween.EASE_IN_OUT)
		tw.tween_property(piece, "global_position", set_held_piece_target_position(piece, i), 0.2)

		
func create_board():
	for i in range(Globals.ROWS[Globals.game_mode]):
		board.append([])
		board[i].resize(Globals.COLS[Globals.game_mode])

func toggle_board():
	for x in range(Globals.ROWS[Globals.game_mode]):
		for y in range(Globals.COLS[Globals.game_mode]):
			if board[x][y]:
				board[x][y].visible = !board[x][y].visible
	current_piece.visible = !current_piece.visible
	next_piece.visible = !next_piece.visible
	current_piece.ghost_piece.visible = !current_piece.ghost_piece.visible
	for piece in held_pieces:
		piece.visible = !piece.visible
	hud.paused_label.visible = !hud.paused_label.visible
	
func check_for_lines(piece : Piece):
	set_process(false)
	var lines_to_check : Array = []
	for tile in piece.tile_data:
		if not lines_to_check.has(piece.current_coords.y + tile.y):
			lines_to_check.append(piece.current_coords.y + tile.y)
	
	var lines_cleared_at_once : int = 0
	if lines_to_check.size() > 0:
		
		lines_to_check.sort()
		var lines_to_move : Array = []
		for line in lines_to_check:
			if check_row(line):
				clear_row(line)
				lines_to_move.append(line)
				lines_cleared += 1
				lines_cleared_at_once += 1
				if lines_cleared % 10 == 0:
					Globals.TICK_DURATION = clampf(Globals.TICK_DURATION - 0.1, 0.05, 1.0)
					Globals.LOCK_DELAY = clampf(Globals.LOCK_DELAY - 0.05, 0.1, 0.5)

		if lines_cleared_at_once > 0:
			var score_gain : int = lines_cleared_at_once * (lines_to_move[lines_to_move.size() - 1] - piece.last_height) * 10 
			if lines_cleared_at_once == 4:
				score_gain *= 1.5
				if check_for_perfect_clear():
					score_gain *= 2
			score += score_gain
			await get_tree().create_timer(0.45).timeout
			move_lines_down(lines_to_move)
		else:
			score += 50	

	score_label.text = "Score: %d" % score
	if score > Globals.high_score[Globals.game_mode]:
		Globals.high_score[Globals.game_mode] = score
	high_score_label.text = "High Score: %d" % Globals.high_score[Globals.game_mode]
	
	await get_tree().create_timer(0.1).timeout
	spawn_piece()
	
	set_process(true)

func move_lines_down(lines_to_move : Array):
	for line in lines_to_move:
		for i in range(line - 1, 0, -1):
			if is_empty(i):
				break
			for j in range(Globals.COLS[Globals.game_mode]):
				if is_instance_valid(board[i][j]):
					board[i][j].position.y += Globals.CELL_SIZE[Globals.game_mode]
				board[i + 1][j] = board[i][j]
				board[i][j] = board[i - 1][j]
	lines_label.text = "Lines: %d" % lines_cleared
	
func check_for_perfect_clear():
	return find_highest_row() < Globals.ROWS[Globals.game_mode] - 1


func scramble_random_row():
	var row_count = Globals.ROWS[Globals.game_mode] - find_highest_row()
	if row_count > 0:
		fill_row_with_garbage(Globals.ROWS[Globals.game_mode] - 1 - randi_range(0, row_count - 1))

func find_highest_row() -> int:
	for i in range(Globals.ROWS[Globals.game_mode] - 1, -1, -1):
		if is_empty(i):
			return i + 1
	return 0

func is_empty(row : int):
	for i in range(Globals.COLS[Globals.game_mode]):
		if board[row][i] != null:
			return false
	return true
		
func check_row(row : int):
	for i in range(Globals.COLS[Globals.game_mode]):
		if board[row][i] == null:
			return false
	return true

func clear_row(row : int):
	for i in range(Globals.COLS[Globals.game_mode]):
		if board[row][i] != null:
			board[row][i].destroy()
			board[row][i] = null

func fill_row_with_garbage(row : int):
	var numbers : Array = []
	for i in range(Globals.COLS[Globals.game_mode]):
		numbers.append(i)
	numbers.shuffle()
	
	clear_row(row)

	for i in randi_range(floor(Globals.COLS[Globals.game_mode] * 0.4), ceil(Globals.COLS[Globals.game_mode] * 0.6)):
		var col = numbers.pop_back()
		var tile : Sprite2D
		if Globals.game_mode == Globals.GameMode.TETRIS:
			tile = tile_scene.instantiate() as Sprite2D
			tile.modulate = Globals.tetris_colors[Globals.tetris_colors.keys().pick_random()]
		else:
			tile = pentris_tile_scene.instantiate() as Sprite2D
			tile.modulate = Globals.pentomino_colors[Globals.pentomino_colors.keys().pick_random()]
		board[row][col] = tile
		tile.position = Vector2(col, row) * Globals.CELL_SIZE[Globals.game_mode]
		board_area.add_child(tile)

func _on_piece_locked(piece : Piece):
	for i in piece.tile_data.size():
		board[piece.current_coords.y + piece.tile_data[i].y][piece.current_coords.x + piece.tile_data[i].x] = piece.tiles[i]
	check_for_lines(piece)

func _on_piece_board_entered(piece : Piece):
	current_piece = piece
	if current_piece.was_held:
		just_released = false
	if Globals.spawn_ghost_piece:
		spawn_piece(true, current_piece)

func _on_piece_released(released_piece : Piece):
	next_piece.queue_free()
	next_piece = released_piece
	next_piece.set_status(NEXT)
	reposition_held_pieces()

func _on_piece_held():
	current_piece = null
	spawn_piece()	
	
func _on_scene_changed():
	spawn_piece()


func _on_board_area_setup_ready() -> void:
	pass # Replace with function body.

func _on_game_over_shown():
	Globals.save_score()	
	$GameOverTimer.start(3.5)
	
func return_to_menu():
	SceneChanger.change_scene("res://scenes/title_screen.tscn")
