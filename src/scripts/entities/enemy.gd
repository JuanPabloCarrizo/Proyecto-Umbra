extends CharacterBody2D

class_name Enemy

@export var speed: float = 150
@export var activation_radius: float = 400.0  # Esto es para que persigan cuando está en radio
@export var id: int
var player: Node2D = null
var is_active: bool = false

# Esto es para que vuelva a custodiar al item
@onready var objeto: Area2D = null


func _ready() -> void:
	player = get_tree().get_nodes_in_group("player")[0]
	var objetos = get_tree().get_nodes_in_group("objetos")
	for o in objetos:
		if o.id == 1 and id in[1,2]:
			print("Entro en ready id 1 in 1 2")
			objeto = o
		elif o.id == 2 and id in [3,4]:
			print("Entro en ready id 1 in 3 4 ")
			objeto = o
		elif o.id == 3 and id in [5,6]:
			print("Entro en ready id 3 in  5 6 ")
			objeto = o

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	var objetos = get_tree().get_nodes_in_group("objetos")
	if player == null:
		return
	
	# calcular distancia
	var distance = position.distance_to(player.position)
	
	# activar si está dentro del radio
	#if distance <= activation_radius:
		#is_active = true
	#else:
		#is_active = false
	if LevelManager.frenzy_mode == true:
		is_active = true
	else:
		is_active = distance <= activation_radius
	
	# seguir al player si ya está activo
	if is_active:
		follow()
	else:
		back_to_position()

func follow():
	velocity = position.direction_to(player.position) * speed
	move_and_slide()


func back_to_position():
	#if (objeto.id == 1) and id in [1,2,3]:
		#velocity = position.direction_to(objeto.position) * speed
		#move_and_slide()
	#else:
		#objeto.id == 3 and id in [4,5,6]
		#velocity = position.direction_to(objeto.position) * speed
		#move_and_slide()
	if objeto != null:
		velocity = position.direction_to(objeto.position) * speed
		move_and_slide()
	

func destroid():
	queue_free()
