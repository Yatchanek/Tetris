extends Node

@onready var color_rect: ColorRect = $CanvasLayer/ColorRect

var target_scene : String

signal scene_changed

func change_scene(_target_scene : String):
	target_scene = _target_scene
	var tw = create_tween()
	tw.finished.connect(_on_tween_finished)
	tw.tween_property(color_rect, "modulate:a", 1.0, 1.0)
	
func _on_tween_finished():
	if color_rect.modulate.a == 1.0:
		if target_scene:
			get_tree().change_scene_to_file(target_scene)
		var tw = create_tween()
		tw.finished.connect(_on_tween_finished)
		tw.tween_property(color_rect, "modulate:a", 0.0, 1.0)
	else:
		await get_tree().create_timer(1.0).timeout
		scene_changed.emit()
