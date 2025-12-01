extends Node


var levels : Array[LevelData]
var main_scene : Node2D = null
var loaded_level : Level = null
# Esto es para el modo Frenzy
var frenzy_mode: bool = false
# Ref: contador-de-recuerdos
var recuerdos_totales := 0
var recuerdos_obtenidos := 0
# REF: esto es para cuando se abre la puerta y el player entra
var door_active = false
# REF esto es para cargar la pantalla final
var final_scree_scene := preload("res://src/scenes/ui/final_screen.tscn")
var tipo_final: String = ""
# REF musica-de-peligro
var enemigos_totales := 0
var enemigos_eliminados := 0



func unload_level() -> void:
	if is_instance_valid(loaded_level):
		loaded_level.queue_free()
	
	loaded_level = null

func load_level(level_id : int) -> void:
	print("LevelManager.load_level() llamado con id:", level_id)
	unload_level()
	
	var level_data = get_level_by_id(level_id)
	if not level_data:
		print("LevelManager: level_data no encontrado para id", level_id)
		return
	
	var level_path = "res://src/scenes/%s.tscn" % level_data.level_path
	#print("LevelManager: intentando cargar path:", level_path)
	
	var level_res := ResourceLoader.load(level_path)
	if not level_res:
		print("LevelManager: ERROR al cargar recurso:", level_path)
		return
	else:
		print("LevelManager: recurso cargado OK:", level_res)
	
	loaded_level = level_res.instantiate()
	if not loaded_level:
		print("LevelManager: ERROR al instanciar recurso")
		return

	var current = get_tree().current_scene
	print("LevelManager: current_scene =", current)
	if current == null:
		print("LevelManager: current_scene es null, intentar agregar al root en su lugar")
		get_tree().root.add_child(loaded_level)
	else:
		# comprobación extra: current acepta hijos
		if is_instance_valid(current):
			current.add_child(loaded_level)
		else:
			print("LevelManager: current_scene no es válido, se agrega al root")
			get_tree().root.add_child(loaded_level)

	# Ref: contador-de-recuerdos
	contar_recuerdos()
	# REF: musica-de-peligro
	contar_enemigos()
	print("LevelManager: nivel instanciado OK")


func get_level_by_id(level_id : int) -> LevelData:
	var level_returning : LevelData = null
	
	for level : LevelData in levels:
		if level.level_id == level_id:
			level_returning = level
	
	return level_returning

# Ref: contador-de-recuerdos
func agregar_recuerdo():
	recuerdos_obtenidos += 1
	print("Recolectados:", recuerdos_obtenidos, "/", recuerdos_totales)


func contar_recuerdos() -> void:
	recuerdos_totales = 0
	
	for o in get_tree().get_nodes_in_group("objetos"):
		print(o.tipo)
		if o.tipo == 1:
			recuerdos_totales += 1
	
	print("Recuerdos totales en mapa: ", recuerdos_totales)


func finalizar_juego() -> void:
	if recuerdos_totales == 0:
		cargar_final("final_malo")
		return

	var porcentaje := float(recuerdos_obtenidos) / float(recuerdos_totales) * 100.0

	if porcentaje < 40.0:
		cargar_final("final_malo")
	elif porcentaje < 100.0:
		cargar_final("final_intermedio")
	else:
		cargar_final("final_bueno")

func cargar_final(tipo: String):
	get_tree().paused = false
	LevelManager.tipo_final = tipo
	get_tree().change_scene_to_file("res://src/scenes/ui/final_screen.tscn")
	

#REF musica-de-peligro
func contar_enemigos() -> void:
	enemigos_totales = 0
	
	for e in get_tree().get_nodes_in_group("enemies"):
		print(e.id)
		if e.id == 1:
			enemigos_totales += 1
	
	print("Enemigos totales en mapa: ", enemigos_totales)
	

#REF musica-de-peligro
func add_eliminated_enemy():
	enemigos_eliminados += 1
	print("Eliminado:", enemigos_eliminados, "/", enemigos_totales)
	
