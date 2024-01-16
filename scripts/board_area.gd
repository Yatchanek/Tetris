extends Node2D

var elapsed_time : float
var time_to_scramble : int

signal setup_ready
signal scramble

func _ready() -> void:
	if Globals.game_mode == Globals.GameMode.TETRIS:
		position = Vector2(470, 60)
	else:
		position = Vector2(462, 28)
	elapsed_time = 0

	await get_tree().process_frame
	setup_ready.emit(position)

func _process(delta: float) -> void:
	if Globals.hardcore_mode:
		elapsed_time += delta
		if elapsed_time >= time_to_scramble:
			scramble.emit()
			elapsed_time = 0
			time_to_scramble = randi_range(30, 40)
	
func _on_label_position_set(next_label_pos : Vector2, held_label_pos : Vector2):
	Globals.next_label_position = to_local(next_label_pos)
	Globals.held_label_position = to_local(held_label_pos)
