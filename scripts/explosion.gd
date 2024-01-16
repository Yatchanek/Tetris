extends GPUParticles2D

func _ready() -> void:
	emitting = true
	await get_tree().create_timer(0.55).timeout
	queue_free()
