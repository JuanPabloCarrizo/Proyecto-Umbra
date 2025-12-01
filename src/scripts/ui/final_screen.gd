extends Control
class_name FinalScreen

@export var img_final_malo: Texture2D
@export var img_final_medio: Texture2D
@export var img_final_bueno: Texture2D
@onready var fondo: TextureRect = $TextureRect
@onready var texto: Label = $TextureRect/Texto
@onready var sfx: AudioStreamPlayer2D = $sfx
@onready var menu_buttons = $TextureRect/MarginContainer/VBoxContainer.get_children()

func _enter_tree() -> void:
	set_process_mode(Node.PROCESS_MODE_ALWAYS)

func _ready() -> void:
	sfx.process_mode = Node.PROCESS_MODE_ALWAYS

	var tipo_final = LevelManager.tipo_final
	mostrar_final(tipo_final)

	# Hover de los botones
	for b in menu_buttons:
		if b is Button:
			b.mouse_entered.connect(_sfx_hover_button)

func mostrar_final(tipo: String) -> void:
	visible = true

	match tipo:
		"player_muere", "final_malo":
			texto.text = "Tu alma está perdida.\nLa oscuridad reclama tu esencia. La penumbra se alimenta una vez mas."
			fondo.texture = img_final_malo
			AudioManager.play_ending_bad()

		"final_intermedio":
			texto.text = "Un destino incierto.\nAún no sabes quién eres. Tus recuerdos no son suficientes y el ciclo quizás se repita eternamente."
			fondo.texture = img_final_medio
			AudioManager.play_ending_mid()

		"final_bueno":
			texto.text = "La luz prevalece sobre el olvido...\nRecuerdas quién eres y el sonido de tu nombre ahora es claro y poderoso."
			fondo.texture = img_final_bueno
			AudioManager.play_ending_good()

	await get_tree().process_frame
	get_tree().paused = true  # congela todo menos el UI

func _sfx_hover_button() -> void:
	sfx.play()

func _on_play_button_pressed() -> void:
	print("boton continuar")
	sfx.play()
	LevelManager.recuerdos_obtenidos = 0
	LevelManager.frenzy_mode = false

	get_tree().paused = false

	# Restaurar música del nivel
	AudioManager.play_level()

	get_tree().change_scene_to_file("res://src/scenes/levels/level_01.tscn")
	deactivate()

func _on_quit_button_pressed() -> void:
	sfx.play()
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
