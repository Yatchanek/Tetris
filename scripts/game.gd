extends Node

var tetromino_scene = preload("res://scenes/tetromino.tscn")

@onready var generator: SevenBagGenerator = $SevenBagGenerator
@onready var board_area: Node2D = $BoardArea
@onready var lines_label: Label = $Hud/MarginContainer/VBoxContainer/LinesLabel
@onready var score_label: Label = $Hud/MarginContainer/VBoxContainer/ScoreLabel


var board : Array = []


var lines_cleared : int = 0
var score : int = 0

var next_piece : Tetromino

func _ready() -> void:
	create_board()
	spawn_tetromino()
	lines_label.text = "Lines cleared: %d" % lines_cleared
	score_label.text = "Score %d" % score

func spawn_tetromino(is_ghost : bool = false, add_ghost_to : Tetromino = null):
	if !is_ghost:
		
		if !next_piece:
			var tetromino : Tetromino
			tetromino = tetromino_scene.instantiate() as Tetromino
			tetromino.tetromino_type = generator.get_piece()
			tetromino.board = board
			tetromino.tetromino_locked.connect(_on_tetromino_locked)
			tetromino.board_entered.connect(_on_tetromino_board_entered)
			board_area.add_child(tetromino)
		else:
			next_piece.activate()
	
		next_piece = tetromino_scene.instantiate() as Tetromino
		next_piece.is_next_piece = true
		next_piece.tetromino_type = generator.get_piece()
		next_piece.board = board
		next_piece.tetromino_locked.connect(_on_tetromino_locked)
		next_piece.board_entered.connect(_on_tetromino_board_entered)
		board_area.add_child(next_piece)	
		
	else:
		var ghost_tetromino = tetromino_scene.instantiate() as Tetromino
		ghost_tetromino.is_ghost = true
		ghost_tetromino.tetromino_type = add_ghost_to.tetromino_type
		ghost_tetromino.board = board
		add_ghost_to.ghost_tetromino = ghost_tetromino
		ghost_tetromino.current_coords = add_ghost_to.current_coords
		ghost_tetromino.position = add_ghost_to.position
		board_area.add_child(ghost_tetromino)
	

func create_board():
	for i in range(20):
		board.append([])
		board[i].resize(10)

func check_for_lines(tetromino : Tetromino):
	var lines_to_check : Array = []
	for tile in tetromino.tile_data:
		if not lines_to_check.has(tetromino.current_coords.y + tile.y):
			lines_to_check.append(tetromino.current_coords.y + tile.y)
	
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
					Globals.TICK_DURATION = wrapf(Globals.TICK_DURATION - 0.1, 0.1, 1.0)
		if lines_cleared_at_once > 0:
			var score_gain : int = lines_cleared_at_once * (lines_to_move[lines_to_move.size() - 1] - tetromino.last_height) * 10 
			if lines_cleared_at_once == 4:
				score_gain *= 1.5
				if check_for_perfect_clear():
					score_gain *= 2
			score += score_gain
		await get_tree().create_timer(0.35).timeout
		move_lines_down(lines_to_move)
	
	score_label.text = "Score %d" % score
	
	await get_tree().create_timer(0.1).timeout
	spawn_tetromino()

func move_lines_down(lines_to_move : Array):
	for line in lines_to_move:
		for i in range(line - 1, 0, -1):
			if is_empty(i):
				break
			for j in range(10):
				if is_instance_valid(board[i][j]):
					board[i][j].position.y += Globals.CELL_SIZE
				board[i + 1][j] = board[i][j]
				board[i][j] = board[i - 1][j]
	lines_label.text = "Lines cleared: %d" % lines_cleared
	
func check_for_perfect_clear():
	for i in range(19, 15, -1):
		if !is_empty(i):
			return false
	return true
func is_empty(row : int):
	for i in range(10):
		if board[row][i] != null:
			return false
	return true
		
func check_row(row : int):
	for i in range(10):
		if board[row][i] == null:
			return false
	return true

func clear_row(row : int):
	for i in range(10):
		board[row][i].destroy()

func _on_tetromino_locked(tetromino : Tetromino):
	tetromino.ghost_tetromino.queue_free()
	for i in tetromino.tile_data.size():
		board[tetromino.current_coords.y + tetromino.tile_data[i].y][tetromino.current_coords.x + tetromino.tile_data[i].x] = tetromino.tiles[i]
	check_for_lines(tetromino)

func _on_tetromino_board_entered(tetromino : Tetromino):
	spawn_tetromino(true, tetromino)
