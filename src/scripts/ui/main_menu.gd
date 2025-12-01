extends Control

class_name MainMenu
@onready var music: AudioStreamPlayer = $music
@onready var sfx: AudioStreamPlayer2D = $sfx
@onready var menu_buttons = $TextureRect/MarginContainer/VBoxContainer.get_children()
@onready var menu_container: VBoxContainer = $TextureRect/MarginContainer/VBoxContainer



func _ready() -> void:
	menu_container.visible = false
	_mostrar_menu_container()
	#REF audio-manager
	AudioManager.play_menu()
	#Para el hover de los botones
	for b in menu_buttons:
		if b is Button:
			b.mouse_entered.connect(_sfx_hover_button)


func _mostrar_menu_container() -> void:
	await get_tree().create_timer(4.0).timeout
	menu_container.visible = true


func _sfx_hover_button() -> void:
	sfx.play()


func _on_play_button_pressed() -> void:
	sfx.play()
	music.stop()
	AudioManager.play_level()
	LevelManager.load_level(1)
	deactivate()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func deactivate() -> void:
	hide()
	set_process(false)
	set_process_unhandled_input(false)
	set_process_input(false)
	set_physics_process(false)


func activate() -> void:
	show()
	set_process(true)
	set_process_unhandled_input(true)
	set_process_input(true)
	set_physics_process(true)
