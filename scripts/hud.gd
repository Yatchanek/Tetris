extends CanvasLayer

@onready var next_label: Label = $NextLabel
@onready var held_label: Label = $HeldLabel

func setup_labels_position(play_area_position: Vector2, play_area_size : Vector2):
	next_label.position = play_area_position + Vector2(play_area_size.x + 74, -20)
	held_label.position = play_area_position + Vector2(play_area_size.x + 74, play_area_size.y - 160)
