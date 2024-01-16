extends CanvasLayer

@onready var panel_container: PanelContainer = $PanelContainer
@onready var border: TextureRect = $Border
@onready var color_rect: ColorRect = $ColorRect

var board_position : Vector2

func _ready() -> void:
	pass

func _on_board_area_setup_ready(_board_position : Vector2) -> void:
	board_position = _board_position
	panel_container.global_position.y = board_position.y - 10
	border.position = Vector2(board_position.x - 10, 0)
	color_rect.position = board_position
	if Globals.game_mode == Globals.GameMode.TETRIS:		
		border.texture = load("res://resources/border.png")
		color_rect.size = Vector2(320, 640)
	else:
		border.texture = load("res://resources/border_pentris.png")
		color_rect.size = Vector2(336, 672)
