extends Node

enum Tetromino {
	I,
	J,
	L,
	O,
	S,
	Z,
	T
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

#const CELL_SIZE : int = 32
#const ROWS : int = 20
#const COLS : int = 10

var TICK_DURATION : float = 1.0
var LOCK_DELAY : float = 0.5

var game_mode : GameMode = GameMode.PENTRIS
var garbage_rows : int = 0
var spawn_ghost_piece : bool = true
var hardcore_mode : bool = false
