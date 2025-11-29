extends Control
class_name FinalScreen


@onready var texto: Label = $TextureRect/Texto
@onready var sfx: AudioStreamPlayer2D = $sfx
@onready var final_malo: AudioStreamPlayer2D = $final_malo
@onready var final_medio: AudioStreamPlayer2D = $final_medio
@onready var final_bueno: AudioStreamPlayer2D = $final_bueno
@onready var menu_buttons = $TextureRect/MarginContainer/VBoxContainer.get_children()


func _enter_tree() -> void:
	set_process_mode(Node.PROCESS_MODE_ALWAYS)


func _ready() -> void:
	sfx.process_mode = Node.PROCESS_MODE_ALWAYS
	final_malo.process_mode = Node.PROCESS_MODE_ALWAYS
	final_medio.process_mode = Node.PROCESS_MODE_ALWAYS
	final_bueno.process_mode = Node.PROCESS_MODE_ALWAYS

	var tipo_final = LevelManager.tipo_final
	mostrar_final(tipo_final)
	#Para el hover de los botones
	for b in menu_buttons:
		if b is Button:
			b.mouse_entered.connect(_sfx_hover_button)


func mostrar_final(tipo: String) -> void:
	#print("MOSTRAR FINAL")
	visible = true
	# Elegís el texto según el final
	match tipo:
		"player_muere":
			texto.text = "Tu alma está perdida."
			final_malo.play()
		"final_malo":
			texto.text = "Has perecido... No lograste retener tus recuerdos."
			final_malo.play()
		"final_intermedio":
			texto.text = "Un destino incierto. No reuniste suficientes recuerdos."
			final_medio.play()
		"final_bueno":
			texto.text = "¡Victoria! Recuperaste todos tus recuerdos."
			final_bueno.play()


	await get_tree().process_frame
	get_tree().paused = true  # Congela todo menos el UI


func _sfx_hover_button() -> void:
	sfx.play()


func _on_play_button_pressed() -> void:
	print("boton continuar")
	LevelManager.recuerdos_obtenidos = 0 # esto es para que resetee 
	LevelManager.frenzy_mode = false
	sfx.play()
	get_tree().paused = false
	# ver como stop la musica
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
