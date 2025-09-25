extends CharacterBody2D
class_name Enemy

@export var speed: float = 150.0
@export var activation_radius: float = 400.0
@export var id: int

var player: Node2D
var is_active: bool = false
var objeto: Area2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
	# asigna objeto según id
	for o in get_tree().get_nodes_in_group("objetos"):
		match [o.id, id]:
			[1, 1], [1, 2]:
				objeto = o
			[2, 3], [2, 4]:
				objeto = o
			[3, 5], [3, 6]:
				objeto = o
	
	if objeto:
		print("Enemigo con id %s custodia objeto %s" % [id, objeto.id])

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
	if objeto:
		velocity = position.direction_to(objeto.position) * speed
		move_and_slide()

func destroid() -> void:
	queue_free()
