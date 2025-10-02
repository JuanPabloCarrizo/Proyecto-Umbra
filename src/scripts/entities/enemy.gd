extends CharacterBody2D
class_name Enemy

@export var speed: float = 200.0
@export var activation_radius: float = 400.0
@export var id: int

var player: Node2D
var is_active: bool = false
var objeto: Area2D
var initial_position: Vector2   # <-- acá guardamos la posición original

func _ready() -> void:
	# guardamos la posición con la que el enemigo está en el mapa
	initial_position = global_position

	player = get_tree().get_first_node_in_group("player")

	# asigna objeto según id de enemigo para que "custodien" a ese objeto
	for o in get_tree().get_nodes_in_group("objetos"):
		match [o.id, id]:
			[1, 1], [1, 2]:
				objeto = o
			[2, 3], [2, 4]:
				objeto = o
			[3, 5], [3, 6]:
				objeto = o
	
	if objeto:
		print("Enemigo con id %s custodia objeto %s en (%s)" % [id, objeto.id, initial_position])

func _process(delta: float) -> void:
	if not player:
		return
	
	var distance := position.distance_to(player.position)
	is_active = LevelManager.frenzy_mode or distance <= activation_radius
	
	if is_active:
		follow()
	else:
		back_to_position()


func follow() -> void:
	velocity = position.direction_to(player.position) * speed
	move_and_slide()


func back_to_position() -> void:
	# ahora el enemigo vuelve al punto en el que lo pusiste en el editor
	var target_position = initial_position
	velocity = position.direction_to(target_position) * speed
	move_and_slide()


func destroid() -> void:
	queue_free()
