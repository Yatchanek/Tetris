extends Node2D
class_name  Tetromino

enum {
	DOWN,
	RIGHT,
	LEFT
}

const MOVE_COOLDOWN : float = 0.033333

@onready var timer: Timer = $Timer

var tile_scene = preload("res://scenes/tile.tscn")

var tile_data : Array
var tetromino_type : Globals.Tetromino
var spawn_coords : Vector2i = Vector2i(4, -1)
var rotation_index : int = 0
var current_coords : Vector2i

var is_ghost : bool = false
var is_next_piece : bool = false

var tiles : Array = []
var board : Array = []
var tick_elapsed_time : float = 0
var move_elapsed_time : float = 0
var ghost_tetromino : Tetromino
var can_accept_input : bool = true
var DAS_framecount : int = 0
var ARR_framecount : int = 0
var key_held : bool = false
var ar_active : bool = false

var last_height : int

signal tetromino_locked
signal board_entered

func _ready() -> void:
	tile_data = Globals.shapes[tetromino_type]
	for point in tile_data:
		var tile = tile_scene.instantiate() as Sprite2D

		tile.region_rect.position.x = tetromino_type * Globals.CELL_SIZE
		tile.tree_exited.connect(_on_tile_removed.bind(tile))
		tiles.append(tile)
		if is_ghost:
			modulate.a = 0.5
			tile.region_rect.position.x = 7 * Globals.CELL_SIZE
		add_child(tile)
	if is_ghost:
		set_process_input(false)
		set_physics_process(false)
		z_index = -1
	elif is_next_piece:
		set_process_input(false)
		set_physics_process(false)
		position = Vector2i(420, 32)
	else:
		current_coords = spawn_coords
		position = Vector2(current_coords * Globals.CELL_SIZE)
	position_blocks()
	
	if !is_ghost and !is_next_piece:
		board_entered.emit(self)
		await get_tree().create_timer(0.1).timeout
		enter_board()


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_up"):
		rotate_clockwise()

	elif Input.is_action_just_pressed("ui_accept"):
		hard_drop()

func _physics_process(delta: float) -> void:
	if key_held:
		DAS_framecount += 1
		if DAS_framecount == 10:
			DAS_framecount = 0
			key_held = false
			ar_active = true
			move_elapsed_time = 0
	
	tick_elapsed_time += delta
	if tick_elapsed_time > Globals.TICK_DURATION:
		last_height = current_coords.y
		var moved = move(Vector2i.DOWN)
		if !moved and timer.is_stopped():
			timer.start()
		elif moved:
			timer.stop()
		tick_elapsed_time = 0
	
	if ar_active:
		ARR_framecount += 1
		if ARR_framecount == 2:
			can_accept_input = true
			ARR_framecount = 0
			
	if Input.is_action_pressed("ui_left") and can_accept_input:
		move(Vector2i.LEFT)
		if !ar_active:
			key_held = true
		can_accept_input = false
	elif Input.is_action_pressed("ui_right") and can_accept_input:
		move(Vector2i.RIGHT)
		key_held = true
		if !ar_active:
			key_held = true
		can_accept_input = false
	elif Input.is_action_pressed("ui_down") and can_accept_input:
		last_height = current_coords.y
		if !move(Vector2i.DOWN) and timer.is_stopped():
			timer.start()

	if Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right"):
		key_held = false
		ar_active = false
		can_accept_input = true
		ARR_framecount = 0
		DAS_framecount = 0

func position_blocks():
	for i in tile_data.size():
		tiles[i].position = tile_data[i] * Globals.CELL_SIZE

func activate():
	is_next_piece = false
	spawn_coords = Vector2i(4, -1)
	set_physics_process(true)
	set_process_input(true)
	board_entered.emit(self)
	enter_board()
	
func enter_board():
	current_coords = spawn_coords
	position = Vector2(current_coords * Globals.CELL_SIZE)
	ghost_tetromino.hard_drop()
	if !move(Vector2i.DOWN):
		set_physics_process(false)
		set_process_input(false)
		await get_tree().create_timer(3.0).timeout
		get_tree().reload_current_scene()
	
		
func move(direction : Vector2i, rotation : int = rotation_index):
	if can_move(direction, rotation):
		current_coords += direction
		position = Vector2(current_coords * Globals.CELL_SIZE)
		if rotation != rotation_index:
			apply_rotation(rotation)
			rotation_index = rotation
		if !is_ghost and !is_next_piece:
			if rotation != ghost_tetromino.rotation_index:
				ghost_tetromino.apply_rotation(rotation)
				ghost_tetromino.rotation_index = rotation
			ghost_tetromino.current_coords = current_coords
			ghost_tetromino.hard_drop()
		return true
	return false

func can_move(direction : Vector2i, rotation : int):
	var _tile_data : Array
	if rotation == rotation_index:
		_tile_data = tile_data
	else:
		_tile_data = get_rotated_data(rotation)
	for tile in _tile_data:
		if current_coords.x + tile.x + direction.x < 0 or current_coords.x + tile.x + direction.x > 9 or current_coords.y + tile.y + direction.y > 19 or board[current_coords.y + direction.y + tile.y][current_coords.x + direction.x + tile.x] != null:
			return false
	return true

func hard_drop():
	last_height = current_coords.y
	while move(Vector2i.DOWN):
		continue
	if !is_ghost and !is_next_piece:
		lock()
	
func rotate_clockwise():
	if tetromino_type == Globals.Tetromino.O:
		return
	var new_index = wrapi(rotation_index + 1, 0, 4)
	var kick_data : Array
	if tetromino_type == Globals.Tetromino.I:
		kick_data = Globals.wall_kick_data[1]
	else:
		kick_data = Globals.wall_kick_data[0]
	for offset in kick_data[new_index]:
		if move(offset, new_index):
			break

func apply_rotation(rotation : int):
	var point_data = get_rotated_data(rotation)
	tile_data = point_data
	position_blocks()

func get_rotated_data(rotation : int) -> Array:
	var rotated_tile_data : Array = []
	var box_size : int = 2
	if tetromino_type == Globals.Tetromino.I:
		box_size = 3
	if tetromino_type == Globals.Tetromino.O:
		return tile_data
	
	var rotated_point : Vector2i
	
	for point in Globals.shapes[tetromino_type]:
		if rotation == 0:
			rotated_point = Vector2i(point.x, point.y)
			
		elif rotation == 1:
			rotated_point = Vector2i(box_size - point.y, point.x)

		elif rotation == 2:
			rotated_point = Vector2i(box_size - point.x, box_size - point.y)
		
		else:
			rotated_point = Vector2i(point.y, box_size - point.x)
		
		rotated_tile_data.append(rotated_point)
	return rotated_tile_data

func lock():
	set_process_input(false)
	set_physics_process(false)
	tetromino_locked.emit(self)
	ghost_tetromino.queue_free()

func _on_tile_removed(tile):
	tiles.erase(tile)
	if tiles.size() == 0:
		queue_free()


func _on_timer_timeout() -> void:
	lock()
