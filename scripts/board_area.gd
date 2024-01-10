extends Node2D

@onready var color_rect: ColorRect = $Border/ColorRect
@onready var border: TextureRect = $Border

signal setup_ready

func _ready() -> void:
	if Globals.game_mode == Globals.GameMode.TETRIS:
		position = Vector2(470, 64)
		border.position = Vector2(-10, -130)
		border.texture = load("res://resources/border.png")
		color_rect.position = Vector2(10, 130)
		color_rect.size = Vector2(320, 640)
	else:
		position = Vector2(462, 32)
		border.position = Vector2(-10, -98)
		border.texture = load("res://resources/border_pentris.png")
		color_rect.position = Vector2(10, 98)
		color_rect.size = Vector2(336, 672)
	
	await get_tree().process_frame	
	setup_ready.emit(global_position, color_rect.size)
