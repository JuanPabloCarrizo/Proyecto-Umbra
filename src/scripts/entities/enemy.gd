extends CharacterBody2D
class_name Enemy

@export var speed: float = 200.0
@export var activation_radius: float = 400.0
@export var id: int
@export var cooldown_golpe: float = 1.0       
@export var fuerza_retroceso: float = 250.0   

var player: Node2D
var is_active: bool = false
var objeto: Area2D
var initial_position: Vector2

var puede_golpear: bool = true          
var velocidad_temporal: Vector2 = Vector2.ZERO
var tiempo_retroceso: float = 0.0       


func _ready() -> void:
	initial_position = global_position
	player = get_tree().get_first_node_in_group("player")

	# Asignación de objeto según id
	for o in get_tree().get_nodes_in_group("objetos"):
		match [o.id, id]:
			[1, 1], [1, 2]:
				objeto = o
			[2, 3], [2, 4]:
				objeto = o
			[3, 5], [3, 6]:
				objeto = o


func _physics_process(delta: float) -> void:
	if not player:
		return
	
	var distance := position.distance_to(player.position)
	is_active = LevelManager.frenzy_mode or distance <= activation_radius
	
	if tiempo_retroceso > 0:
		velocity = velocidad_temporal
		tiempo_retroceso -= delta
	else:
		if is_active:
			follow_logic()
		else:
			back_to_position_logic()

	move_and_slide()

	# Revisar colisiones con Player
	var colisiones = get_slide_collision_count()
	for i in range(colisiones):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is Player and puede_golpear:
			ataque(collider)


func follow_logic() -> void:
	velocity = position.direction_to(player.position) * speed


func back_to_position_logic() -> void:
	var target_position = initial_position
	velocity = position.direction_to(target_position) * speed


func ataque(player: Player) -> void:
	if not puede_golpear:
		return

	player.recibe_daño(1)
	puede_golpear = false

	# Configura retroceso temporal
	var direccion_retroceso = (global_position - player.global_position).normalized()
	velocidad_temporal = direccion_retroceso * fuerza_retroceso
	tiempo_retroceso = 0.8 

	start_cooldown()


func start_cooldown() -> void:
	await get_tree().create_timer(cooldown_golpe).timeout
	puede_golpear = true


func destroid() -> void:
	queue_free()
