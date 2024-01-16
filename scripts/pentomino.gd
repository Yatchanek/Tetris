extends Piece
class_name Pentomino

var tile_scene : PackedScene = preload("res://scenes/pentris_tile.tscn")



func _ready() -> void:
	tile_data = Globals.pentomino_shapes[piece_type]
	spawn_coords = Vector2i(5, -1)
	for point in tile_data:
		var tile = tile_scene.instantiate() as Sprite2D
		tile.modulate = Globals.pentomino_colors[piece_type]
		tile.region_rect.position.y = Globals.tile_design * Globals.CELL_SIZE[Globals.GameMode.PENTRIS]
		tile.tree_exited.connect(_on_tile_removed.bind(tile))
		tiles.append(tile)
		if status == GHOST:
			tile.modulate = Color(0.6, 0.6, 0.6, 0.5)
			tile.region_rect.position.x = Globals.CELL_SIZE[Globals.GameMode.PENTRIS]
	
		add_child(tile)
	super()
	position_blocks()
	

func rotate_self(direction : int):
	if piece_type == Globals.Pentomino.X:
		return
	var new_index = wrapi(rotation_index + direction, 0, 4)
	var kick_data : Array = get_kick_data(direction)
	for offset in kick_data:
		if move(offset, new_index):
			break
	
func get_bonding_box_size() -> int:
	if piece_type == Globals.Pentomino.I:
		return 4
	elif [Globals.Pentomino.J, Globals.Pentomino.L, Globals.Pentomino.Y,\
	Globals.Pentomino.Y2, Globals.Pentomino.S, Globals.Pentomino.N].has(piece_type): 
		return 3
	return 2

func get_rotated_data(rot_idx : int) -> Array:
	var rotated_tile_data : Array = []
	var box_size = get_bonding_box_size()
	var rotated_point : Vector2i
	
	var shapes_data : Dictionary = Globals.pentomino_shapes
	
	for point in shapes_data[piece_type]:
		if rot_idx == 0:
			rotated_point = Vector2i(point.x, point.y)
			
		elif rot_idx == 1:
			rotated_point = Vector2i(box_size - point.y, point.x)
			if [Globals.Pentomino.L, Globals.Pentomino.J, Globals.Pentomino.Y, Globals.Pentomino.Y2, Globals.Pentomino.S, Globals.Pentomino.N, Globals.Pentomino.P, Globals.Pentomino.B].has(piece_type):
				rotated_point += Vector2i.RIGHT

		elif rot_idx == 2:
			rotated_point = Vector2i(box_size - point.x, box_size - point.y)
			if [Globals.Pentomino.L, Globals.Pentomino.J, Globals.Pentomino.Y, Globals.Pentomino.Y2, Globals.Pentomino.S, Globals.Pentomino.N, Globals.Pentomino.P, Globals.Pentomino.B].has(piece_type):
				rotated_point += Vector2i.DOWN	
		else:
			rotated_point = Vector2i(point.y, box_size - point.x)
			if [Globals.Pentomino.L, Globals.Pentomino.J, Globals.Pentomino.Y, Globals.Pentomino.Y2, Globals.Pentomino.S, Globals.Pentomino.N, Globals.Pentomino.P, Globals.Pentomino.B].has(piece_type):
				rotated_point += Vector2i.LEFT
		
		rotated_tile_data.append(rotated_point)
	return rotated_tile_data

func get_kick_data(rotation_dir) -> Array:
	var kick_data : Array
	
	if piece_type == Globals.Pentomino.I:
		kick_data = Globals.pentomino_wall_kick_data[0]
	else:
		kick_data = Globals.pentomino_wall_kick_data[1]

	return kick_data

