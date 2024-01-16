extends CanvasLayer

@onready var paused_label: Label = $PausedLabel
@onready var touch_controls: Node2D = $TouchControls
@onready var game: HBoxContainer = $Game
@onready var over: HBoxContainer = $Over


signal game_over_shown


func _ready() -> void:
	Globals.game_over.connect(show_game_over)


func show_game_over():
	var tw : Tween = create_tween()

	tw.finished.connect(shown_game_over)
	tw.set_ease(Tween.EASE_IN_OUT)
	tw.set_trans(Tween.TRANS_EXPO)
	tw.tween_property(game, "global_position:x", 700.0, 0.5).as_relative()
	tw.tween_property(over, "global_position:x", -700.0, 0.5).as_relative()
	#await get_tree().create_timer(0.15).timeout
		
func shown_game_over():
	game_over_shown.emit()
