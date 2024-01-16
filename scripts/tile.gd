extends Sprite2D

func destroy():
	var previous_modulate : Color = modulate
	var tw : Tween = create_tween()
	tw.finished.connect(queue_free)
	tw.set_loops(3)
	tw.tween_property(self, "modulate", Color.WHITE, 0.05)
	tw.tween_property(self, "modulate", previous_modulate, 0.05)
	tw.chain()
	tw.tween_property(self, "modulate", Color(1, 1, 1, 0.0), 0.05)
