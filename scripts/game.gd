extends Node

const tetromino_scene = preload("res://scenes/tetromino.tscn")
const pentomino_scene = preload("res://scenes/pentomino.tscn")
const tile_scene = preload("res://scenes/tile.tscn")

@onready var generator: SevenBagGenerator = $BagGenerator
@onready var board_area: Node2D = $BoardArea
@onready var lines_label: Label = $Hud/MarginContainer/VBoxContainer/LinesLabel
@onready var score_label: Label = $Hud/MarginContainer/VBoxContainer/ScoreLabel

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
var held_piece : Piece
var held_pieces : Array[Piece] = []

var elapsed_time : float = 0
var time_to_scramble : int

var just_released : bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			current_piece.set_physics_process(false)
			current_piece.set_process_input(false)
			SceneChanger.change_scene("res://scenes/title_screen.tscn")
			
		elif event.pressed and event.keycode == KEY_G:
			if Globals.hardcore_mode:
				return
			Globals.spawn_ghost_piece = !Globals.spawn_ghost_piece
			if Globals.spawn_ghost_piece:
				spawn_piece(true, current_piece)
			else:
				current_piece.ghost_piece.queue_free()

		elif event.pressed and event.keycode == KEY_H:
			if held_pieces.size() < 3:
				current_piece.set_status(HELD, held_pieces.size())
				current_piece.ghost_piece.queue_free()
				held_pieces.append(current_piece)
				spawn_piece()
				
		elif event.pressed and event.keycode == KEY_R:
			if held_pieces.size() > 0 and not just_released:
				next_piece.queue_free()
				next_piece = held_pieces.pop_back()
				next_piece.set_status(NEXT)
				just_released = true

func _ready() -> void:
	SceneChanger.scene_changed.connect(_on_scene_changed)
	if Globals.hardcore_mode:
		Globals.spawn_ghost_piece = false
		set_process(true)
	create_board()
	
	for i in range(Globals.ROWS[Globals.game_mode] - 1, Globals.ROWS[Globals.game_mode] - Globals.garbage_rows - 1, -1):
		fill_row_with_garbage(i)
		
	lines_label.text = "Lines cleared: %d" % lines_cleared
	score_label.text = "Score %d" % score
	time_to_scramble = randi_range(30, 40)

func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= time_to_scramble:
		scramble_random_row()
		elapsed_time = 0
		time_to_scramble = randi_range(30, 40)

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

func create_board():
	for i in range(Globals.ROWS[Globals.game_mode]):
		board.append([])
		board[i].resize(Globals.COLS[Globals.game_mode])

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
			
		await get_tree().create_timer(0.35).timeout
		move_lines_down(lines_to_move)
	
	score_label.text = "Score %d" % score
	
	await get_tree().create_timer(0.1).timeout
	spawn_piece()
	
	if Globals.hardcore_mode:
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
	lines_label.text = "Lines cleared: %d" % lines_cleared
	
func check_for_perfect_clear():
	for i in range(Globals.ROWS[Globals.game_mode] - 1, Globals.ROWS[Globals.game_mode] - 5, -1):
		if !is_empty(i):
			return false
	return true

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

func fill_row_with_garbage(row : int):
	var numbers : Array = []
	for i in range(Globals.COLS[Globals.game_mode]):
		numbers.append(i)
	numbers.shuffle()
	
	clear_row(row)
	
	for i in range(5):
		var col = numbers.pop_back()
		var tile = tile_scene.instantiate() as Sprite2D
		tile.region_rect.position.x = randi() % 7 * Globals.CELL_SIZE[Globals.game_mode]
		board[row][col] = tile
		tile.position = Vector2(col, row) * Globals.CELL_SIZE[Globals.game_mode]
		board_area.add_child(tile)

func _on_piece_locked(piece : Piece):
	just_released = false
	for i in piece.tile_data.size():
		board[piece.current_coords.y + piece.tile_data[i].y][piece.current_coords.x + piece.tile_data[i].x] = piece.tiles[i]
	check_for_lines(piece)

func _on_piece_board_entered(piece : Piece):
	current_piece = piece
	if Globals.spawn_ghost_piece:
		spawn_piece(true, current_piece)

func _on_scene_changed():
	spawn_piece()
