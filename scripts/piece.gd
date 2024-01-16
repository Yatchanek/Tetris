extends Node2D
class_name Piece


enum {
	DOWN,
	RIGHT,
	LEFT
}

enum {
	ACTIVE,
	NEXT,
	HELD,
	GHOST
}

const MOVE_COOLDOWN : float = 0.033333

var tile_data : Array
var piece_type : int
var tetromino_type : Globals.Tetromino
var pentomino_type : Globals.Pentomino
var spawn_coords : Vector2i
var rotation_index : int = 0
var current_coords : Vector2i
var ghost_tile_index : int
var status : int

var is_ghost : bool = false
var is_next_piece : bool = false

var tiles : Array = []
var board : Array = []
var tick_elapsed_time : float = 0
var move_elapsed_time : float = 0
var lock_elapsed_time : float = 0
var ghost_piece : Piece
var can_accept_input : bool = true
var DAS_framecount : int = 0
var ARR_framecount : int = 0
var key_held : bool = false
var ar_active : bool = false
var countdown_to_lock : bool = false

var was_held : bool = false

var last_height : int

signal piece_locked
signal board_entered
signal game_over


func _ready() -> void:
	set_physics_process(status == ACTIVE)
	set_process_input(status == ACTIVE)
	if status == GHOST:
		z_index = -1

	elif status == ACTIVE:
		enter_board()

func set_status(_status : int):
	status = _status
	if status == HELD:
		was_held = true
		set_physics_process(false)
		set_process_input(false)

	elif status == NEXT:
		set_physics_process(false)
		set_process_input(false)
		
	elif status == ACTIVE:
		activate()

func _physics_process(delta: float) -> void:
	if key_held:
		DAS_framecount += 1
		if DAS_framecount == 10:
			DAS_framecount = 0
			key_held = false
			ar_active = true
			move_elapsed_time = 0
	if ar_active:
		ARR_framecount += 1
		if ARR_framecount == 2:
			can_accept_input = true
			ARR_framecount = 0
			
	if countdown_to_lock:
		lock_elapsed_time += delta
		if lock_elapsed_time >= Globals.LOCK_DELAY and !can_move(Vector2i.DOWN, rotation_index):
			lock()
			
	tick_elapsed_time += delta
	if tick_elapsed_time > Globals.TICK_DURATION:
		last_height = current_coords.y
		var moved = move(Vector2i.DOWN)
		if !moved and !countdown_to_lock:
			countdown_to_lock = true
			lock_elapsed_time = 0
		elif moved:
			countdown_to_lock = false

		tick_elapsed_time = 0
	
	if Input.is_action_just_pressed("rotate_right"):
		rotate_self(1)
	elif Input.is_action_just_pressed("rotate_left"):
		rotate_self(-1)
	elif Input.is_action_just_pressed("hard_drop"):
		hard_drop()
			
	elif Input.is_action_pressed("move_left") and can_accept_input:
		var moved : bool = move(Vector2i.LEFT)
		if moved:
			if !ar_active:
				key_held = true
				can_accept_input = false
	elif Input.is_action_pressed("move_right") and can_accept_input:
		var moved = move(Vector2i.RIGHT)
		if moved:
			if !ar_active:
				key_held = true
			can_accept_input = false
	elif Input.is_action_pressed("soft_drop") and can_accept_input:
		last_height = current_coords.y
		if !move(Vector2i.DOWN) and !countdown_to_lock:
			countdown_to_lock = true
			lock_elapsed_time = 0

	elif Input.is_action_just_released("move_left") or Input.is_action_just_released("move_right"):
		key_held = false
		ar_active = false
		can_accept_input = true
		ARR_framecount = 0
		DAS_framecount = 0

func position_blocks():
	for i in tile_data.size():
		tiles[i].position = tile_data[i] * Globals.CELL_SIZE[Globals.game_mode]

func activate():
	enter_board()
	
func enter_board():
	set_physics_process(true)
	set_process_input(true)
	current_coords = spawn_coords
	position = Vector2(current_coords * Globals.CELL_SIZE[Globals.game_mode])
	board_entered.emit(self)
	
	if !move(Vector2i.DOWN):
		set_physics_process(false)
		set_process_input(false)
		if is_instance_valid(ghost_piece):
			ghost_piece.queue_free()
		Globals.game_over.emit()
	elif is_instance_valid(ghost_piece):
		ghost_piece.hard_drop()

		
func move(direction : Vector2i, rot_idx : int = rotation_index):
	if can_move(direction, rot_idx):
		current_coords += direction
		position = Vector2(current_coords * Globals.CELL_SIZE[Globals.game_mode])
		if rot_idx != rotation_index:
			apply_rotation(rot_idx)
			rotation_index = rot_idx
		if !is_ghost and !is_next_piece:
			if is_instance_valid(ghost_piece):
				if rot_idx != ghost_piece.rotation_index:
					ghost_piece.apply_rotation(rot_idx)
					ghost_piece.rotation_index = rot_idx
				ghost_piece.current_coords = current_coords
				ghost_piece.position = position
				ghost_piece.hard_drop()
		return true
	
	return false

func can_move(direction : Vector2i, rot_idx : int):
	var _tile_data : Array
	if rot_idx == rotation_index:
		_tile_data = tile_data
	else:
		_tile_data = get_rotated_data(rot_idx)
	for tile in _tile_data:
		if current_coords.x + tile.x + direction.x < 0 or current_coords.x + tile.x + direction.x > Globals.COLS[Globals.game_mode] - 1 or current_coords.y + tile.y + direction.y > Globals.ROWS[Globals.game_mode] - 1 or board[current_coords.y + direction.y + tile.y][current_coords.x + direction.x + tile.x] != null:
			return false
	return true

func hard_drop():
	last_height = current_coords.y
	while move(Vector2i.DOWN):
		continue
	if !is_ghost and !is_next_piece:
		lock()

func rotate_self(direction : int):
	var new_index = wrapi(rotation_index + direction, 0, 4)
	var kick_data : Array = get_kick_data(direction)
					
	for offset in kick_data[new_index]:
		if move(offset, new_index):
			break

func apply_rotation(rot_idx : int):
	var point_data = get_rotated_data(rot_idx)
	tile_data = point_data
	position_blocks()
	
func get_rotated_data(rot_idx : int) -> Array:
	return []

func get_bonding_box_size() -> int:
	return 0

func lock():
	set_process_input(false)
	set_physics_process(false)
	piece_locked.emit(self)
	if is_instance_valid(ghost_piece):
		ghost_piece.queue_free()

func get_kick_data(_direction : int) -> Array:
	return []
	
func _on_tile_removed(tile):
	tiles.erase(tile)
	if tiles.size() == 0:
		queue_free()
