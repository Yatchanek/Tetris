extends Node

enum Tetromino {
	I,
	J,
	L,
	T,
	S,
	Z,
	O
}

enum Pentomino {
	I,
	J,
	L,
	X,
	W,
	P,
	B,
	F,
	F2,
	V,
	U,
	Y,
	Y2,
	N,
	S,
	Z,
	Z2,
	T
}

enum GameMode {
	TETRIS,
	PENTRIS
}

const shapes : Dictionary = {
	Tetromino.I : [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)],
	Tetromino.S : [Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 0), Vector2i(2, 0)],
	Tetromino.Z : [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)],
	Tetromino.T : [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
	Tetromino.L : [Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
	Tetromino.J : [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)],
	Tetromino.O : [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1)]
}

const tetris_colors : Dictionary = {
	Tetromino.I : Color(0, 0.93, 0.98),
	Tetromino.J : Color(0, 0.2, 0.98),
	Tetromino.L : Color(1, 0.57, 0.05),
	Tetromino.O : Color(1, 0.98, 0.2),
	Tetromino.S : Color(0.32, 1, 0),
	Tetromino.Z : Color(1, 0.09, 0.12),
	Tetromino.T : Color(0.87, 0, 1)
	
}

const pentomino_shapes : Dictionary = {
	Pentomino.I  : [Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2)],
	Pentomino.J  : [Vector2i(0, 2), Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3)],
	Pentomino.L  : [Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3), Vector2i(3, 2)],
	Pentomino.X  : [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(0, 1), Vector2i(2, 1)],
	Pentomino.W  : [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)],
	Pentomino.P  : [Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2)],
	Pentomino.B  : [Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(1, 1), Vector2i(2, 1)],
	Pentomino.F  : [Vector2i(0, 1), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 0)],
	Pentomino.F2 : [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 1)],
	Pentomino.V  : [Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2)],
	Pentomino.U  : [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 0)],
	Pentomino.Y  : [Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3), Vector2i(2, 2)],
	Pentomino.Y2 : [Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3), Vector2i(1, 2)],
	Pentomino.N  : [Vector2i(0, 2), Vector2i(1, 2), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3)],
	Pentomino.S  : [Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(2, 2), Vector2i(3, 2)],
	Pentomino.Z  : [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)],
	Pentomino.Z2 : [Vector2i(0, 2), Vector2i(1, 2), Vector2i(1, 1), Vector2i(1, 0), Vector2i(2, 0)],
	Pentomino.T  : [Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(1, 1), Vector2i(1, 0)]
}

const pentomino_colors : Dictionary = {
	Pentomino.I  : Color(0, 0.93, 0.98),
	Pentomino.J  : Color(0, 0.2, 0.98),
	Pentomino.L  : Color(1, 0.57, 0.05),
	Pentomino.X  : Color(1, 0.98, 0.2),
	Pentomino.W  : Color(0.32, 1, 0),
	Pentomino.P  : Color(1, 0.09, 0.12),
	Pentomino.B  : Color(0.87, 0, 1),
	Pentomino.F  : Color(1, 0.55, 0.22),
	Pentomino.F2 : Color.WHITE,
	Pentomino.V  : Color(0.48, 0, 1),
	Pentomino.U  : Color(0, 1, 0.57),
	Pentomino.Y  : Color(1, 0, 0.36),
	Pentomino.Y2 : Color(1, 0.98, 0.43),
	Pentomino.N  : Color(0.88, 1, 0.52),
	Pentomino.S  : Color(1, 0.56, 0.52), 
	Pentomino.Z  : Color(0.48, 0, 1),
	Pentomino.Z2 : Color(1, 0.7, 0.74),
	Pentomino.T  : Color(1, 0.34, 0.58)
}

const wall_kick_data_clockwise : Array = [
	#I piece
	[
		[Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -2), Vector2i(-1, -2)],
		[Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, 2), Vector2i(-1, 2)],
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, -2), Vector2i(1, -2)],
		[Vector2i(0, 0), Vector2i(-1, 0), Vector2i(1, -1), Vector2i(0, 2), Vector2i(1, 2)]
	],
	#Others
	[
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(-2, 0), Vector2i(1, 2), Vector2i(-2, -1)],
		[Vector2i(0, 0), Vector2i(-2, 0), Vector2i(1, 0), Vector2i(-2, 1), Vector2i(1, -2)],
		[Vector2i(0, 0), Vector2i(2, 0), Vector2i(-1, 0), Vector2i(2, -1), Vector2i(-1, 2)],
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(-2, 0), Vector2i(1, 2), Vector2i(-2, -1)]		
	]
]

const wall_kick_data_anticlockwise : Array = [
	#I piece
	[
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, -2), Vector2i(1, -2)],
		[Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, 2), Vector2i(-1, 2)],
		[Vector2i(0, 0), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -2), Vector2i(-1, -2)],
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, 2), Vector2i(1, 2)]
	],
	#others
	[
		[Vector2i(0, 0), Vector2i(2, 0), Vector2i(-1, 0), Vector2i(2, -1), Vector2i(-1, 2)],
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(-2, 0), Vector2i(1, 2), Vector2i(-2, -1)],
		[Vector2i(0, 0), Vector2i(-2, 0), Vector2i(1, 0), Vector2i(-2, 1), Vector2i(1, -2)],
		[Vector2i(0, 0), Vector2i(-1, 0), Vector2i(2, 0), Vector2i(-1, -2), Vector2i(2, 1)]		
	]
]

const pentomino_wall_kick_data : Array = [
	#I piece
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0),  Vector2i(2, 0),  Vector2i(-2, 0),  Vector2i(0, -1), Vector2i(0, -2)],
	#Others	
	[Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0),  Vector2i(2, 0),  Vector2i(-2, 0),  Vector2i(0, -1)]
]



const CELL_SIZE : Dictionary = {
	GameMode.TETRIS : 32,
	GameMode.PENTRIS : 28
}

const ROWS : Dictionary = {
	GameMode.TETRIS : 20,
	GameMode.PENTRIS : 24
}

const COLS : Dictionary = {
	GameMode.TETRIS : 10,
	GameMode.PENTRIS : 12
}

var TICK_DURATION : float = 1.0
var LOCK_DELAY : float = 0.5

const max_held_pieces : int = 4

var next_container_position : Vector2
var held_container_position : Vector2

var high_score : Dictionary = {
	GameMode.TETRIS : 0,
	GameMode.PENTRIS : 0
}

var game_mode : GameMode = GameMode.TETRIS
var garbage_rows : int = 0
var spawn_ghost_piece : bool = true
var hardcore_mode : bool = false
var tile_design : int = 0

func save_score():
	var file = FileAccess.open("user://highscore.dat", FileAccess.WRITE)
	file.store_32(high_score[GameMode.TETRIS])
	file.store_32(high_score[GameMode.PENTRIS])

func load_score():
	if FileAccess.file_exists("user://highscore.dat"):
		var file = FileAccess.open("user://highscore.dat", FileAccess.READ)
		high_score[GameMode.TETRIS] = file.get_32()
		high_score[GameMode.PENTRIS] = file.get_32()
		
signal game_over
