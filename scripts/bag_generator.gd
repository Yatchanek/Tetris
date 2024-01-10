extends Node
class_name SevenBagGenerator

var bag : Array[int]

func _ready() -> void:
	pass
		
func get_piece() -> int:
	if bag.size() == 0:
		fill_bag()
	var piece : int = bag.pop_back()
	return piece
	
func fill_bag():
	if Globals.game_mode == Globals.GameMode.TETRIS:
		for tetromino in Globals.Tetromino.values():
			bag.append(tetromino)
	else:
		for pentomino in Globals.Pentomino.values():
			bag.append(pentomino)
	bag.shuffle()
