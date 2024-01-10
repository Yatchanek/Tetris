extends Piece
class_name Tetromino

var tile_scene : PackedScene = preload("res://scenes/tile.tscn")



func _ready() -> void:
	tile_data = Globals.shapes[piece_type]
	spawn_coords = Vector2i(4, -1)
	for point in tile_data:
		var tile = tile_scene.instantiate() as Sprite2D
		tile.region_rect.position.x = piece_type * Globals.CELL_SIZE[Globals.GameMode.TETRIS]
		tile.tree_exited.connect(_on_tile_removed.bind(tile))
		tiles.append(tile)
		if status == GHOST:
			modulate.a = 0.5
			tile.region_rect.position.x = 7 * Globals.CELL_SIZE[Globals.GameMode.TETRIS]
		add_child(tile)
	super()
	
	position_blocks()
	

func rotate_self(direction : int):
	if piece_type == Globals.Tetromino.O:
		return
	super(direction)

func get_rotated_data(rot_idx : int) -> Array:
	var rotated_tile_data : Array = []
	var box_size = get_bonding_box_size()
	var rotated_point : Vector2i
	
	var shapes_data : Dictionary = Globals.shapes
	
	for point in shapes_data[piece_type]:
		if rot_idx == 0:
			rotated_point = Vector2i(point.x, point.y)
			
		elif rot_idx == 1:
			rotated_point = Vector2i(box_size - point.y, point.x)

		elif rot_idx == 2:
			rotated_point = Vector2i(box_size - point.x, box_size - point.y)
		
		else:
			rotated_point = Vector2i(point.y, box_size - point.x)
		
		rotated_tile_data.append(rotated_point)
	return rotated_tile_data

func get_bonding_box_size() -> int:
	if piece_type == Globals.Tetromino.I:
		return 3
	else: 
		return 2

func get_kick_data(rotation_dir) -> Array:
	var kick_data : Array
	
	if rotation_dir > 0:
		if tetromino_type == Globals.Tetromino.I:
			kick_data = Globals.wall_kick_data_clockwise[1]
		else:
			kick_data = Globals.wall_kick_data_clockwise[0]
	else:
		if tetromino_type == Globals.Tetromino.I:
			kick_data = Globals.wall_kick_data_anticlockwise[1]
		else:
			kick_data = Globals.wall_kick_data_anticlockwise[0]
	
	return kick_data


