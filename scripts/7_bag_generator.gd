extends Node
class_name SevenBagGenerator

var bag : Array[Globals.Tetromino]

func _ready() -> void:
	pass
		
func get_piece() -> Globals.Tetromino:
	if bag.size() == 0:
		fill_bag()
	var piece : Globals.Tetromino = bag.pop_back()
	return piece
	
func fill_bag():
	for tetromino in Globals.Tetromino.values():
		bag.append(tetromino)	
	bag.shuffle()
