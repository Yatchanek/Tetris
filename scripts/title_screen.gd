extends Control

@onready var title_letters: HBoxContainer = $TittleLetters
@onready var rainbow_title: RichTextLabel = $RainbowTitle
@onready var garbage_rows_slider: HSlider = $InfoPanel/Carousel/OptionsData/Options/GarbageRowsOption/GarbageRows/GarbageRowsSlider
@onready var ghost_piece_button: CheckButton = $InfoPanel/Carousel/OptionsData/Options/GhostPieceOption/HBoxContainer/HBoxContainer/GhostPieceButton
@onready var hardcore_mode_button: CheckButton = $InfoPanel/Carousel/OptionsData/Options/HardcoreModeOption/HBoxContainer/HBoxContainer/HardcoreModeButton
@onready var info_panel: Panel = $InfoPanel
@onready var tetris_check_box: CheckBox = $InfoPanel/Carousel/OptionsData/Options/GameModeOption/HBoxContainer/TetrisCheckBox
@onready var pentris_check_box: CheckBox = $InfoPanel/Carousel/OptionsData/Options/GameModeOption/HBoxContainer/PentrisCheckBox
@onready var start_game_button: Button = $StartGameButton
@onready var options_button: Button = $OptionsButton
@onready var info_button: Button = $InfoButton
@onready var quit_button: Button = $QuitButton
@onready var carousel: HBoxContainer = $InfoPanel/Carousel

var menu_buttons : Array

func _ready() -> void:
	garbage_rows_slider.value = Globals.garbage_rows
	ghost_piece_button.button_pressed = Globals.spawn_ghost_piece
	hardcore_mode_button.button_pressed = Globals.hardcore_mode
	tetris_check_box.button_pressed = Globals.game_mode == Globals.GameMode.TETRIS
	pentris_check_box.button_pressed = Globals.game_mode == Globals.GameMode.PENTRIS
	
	menu_buttons = get_tree().get_nodes_in_group("MenuButtons")
	
	for i in title_letters.get_children().size():
		drop_letter(i)
		await get_tree().create_timer(0.1).timeout	
	

func drop_letter(letter_number : int):
	var tween : Tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(title_letters.get_child(letter_number), "position:y", 200.0, 0.3)
	if letter_number == title_letters.get_child_count() - 1:
		tween.finished.connect(_on_title_shown)

func move_in_button(button: Button, button_idx : int):
	var tw : Tween = create_tween().set_trans(Tween.TRANS_ELASTIC)
	tw.tween_property(button, "position:x", 100 + button_idx * 50, 1.0)
	
		
func _on_title_shown():
	await get_tree().create_timer(0.5).timeout
	var tw : Tween = create_tween()
	tw.finished.connect(_on_options_shown)
	tw.set_parallel()
	tw.tween_property(title_letters, "modulate:a", 0.0, 0.5)
	tw.tween_property(rainbow_title, "modulate:a", 1.0, 1.0)
	tw.set_parallel(false)
	rainbow_title.append_text("[wave amp=130.0 freq=2.0 connected=1][rainbow freq=.5][center][outline_size=10]Block Mayhem[/outline_size][/center][/rainbow][/wave]")
	for i in range(menu_buttons.size()):
		move_in_button(menu_buttons[i], i)
		await get_tree().create_timer(0.1).timeout
	
func _on_options_shown():
	garbage_rows_slider.editable = true
	
func _on_garbage_rows_value_changed(value: float) -> void:
	Globals.garbage_rows = value

func _on_ghost_piece_button_toggled(toggled_on: bool) -> void:
	Globals.spawn_ghost_piece = toggled_on


func _on_hardcore_mode_button_toggled(toggled_on: bool) -> void:
	Globals.hardcore_mode = toggled_on


func _on_start_game_button_pressed() -> void:
	start_game_button.disabled = true
	SceneChanger.change_scene("res://scenes/game.tscn")


func _on_info_button_pressed() -> void:
	if !info_panel.visible:
		info_panel.show()
		carousel.position.x = -700
	else:
		if carousel.position.x == -700:
			info_panel.hide()
		else:
			var tw : Tween = create_tween()
			tw.tween_property(carousel, "position:x", -700, 0.15)
			
func _on_options_button_pressed() -> void:
	if !info_panel.visible:
		info_panel.show()
		carousel.position.x = 0
	else:
		if carousel.position.x == 0:
			info_panel.hide()
		else:
			var tw : Tween = create_tween()
			tw.tween_property(carousel, "position:x", 0, 0.15)


func _on_info_close_button_pressed() -> void:
	info_panel.hide()


func _on_tetris_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Globals.game_mode = Globals.GameMode.TETRIS
	else:
		Globals.game_mode = Globals.GameMode.PENTRIS


func _on_pentris_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Globals.game_mode = Globals.GameMode.PENTRIS
	else:
		Globals.game_mode = Globals.GameMode.TETRIS


func _on_quit_button_pressed() -> void:
	quit_button.disabled = true
	get_tree().quit()



