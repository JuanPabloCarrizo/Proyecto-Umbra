extends CharacterBody2D
class_name Enemy

@export var speed: float = 200.0
@export var activation_radius: float = 400.0
@export var id: int
@export var cooldown_golpe: float = 1.0       
@export var fuerza_retroceso: float = 250.0   
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D

var player: Node2D
var is_active: bool = false
var objeto: Area2D
var initial_position: Vector2
var puede_golpear: bool = true          
var velocidad_temporal: Vector2 = Vector2.ZERO
var tiempo_retroceso: float = 0.0       
var is_dying = false # Esto es si el enemigo está muerto, lo detengo y hago anim("hit")
var player_is_dead = false # Esto es para la signal de player muerto


func _ready() -> void:
	initial_position = global_position
	player = get_tree().get_first_node_in_group("player")
	player.player_dead.connect(_on_player_dead)
	

func _physics_process(delta: float) -> void:
	if not player:
		return
	# REF Dialogo
	if LevelManager.input_locked:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var distance := position.distance_to(player.position)
	
	#is_active = LevelManager.frenzy_mode or distance <= activation_radius

	var frenzy_affects_me = LevelManager.frenzy_mode and (LevelManager.frenzy_id == -1 or LevelManager.frenzy_id == id)
	is_active = frenzy_affects_me or distance <= activation_radius

	
	if tiempo_retroceso > 0:
		velocity = velocidad_temporal
		tiempo_retroceso -= delta
	else:
		if is_active:
			follow()
		else:
			back_to_position()

	move_and_slide()

	# Revisar colisiones con Player
	var colisiones = get_slide_collision_count()
	for i in range(colisiones):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is Player and puede_golpear:
			ataque(collider)


func follow() -> void:
	# Si el player murio o el enemigo está muriendo
	if player_is_dead or is_dying:
		velocity = Vector2.ZERO
		return
		
	velocity = position.direction_to(player.position) * speed

	if abs(velocity.x) > 10:
		animated_sprite_2d.flip_h = velocity.x > 0


func back_to_position() -> void:
	var target_position = initial_position
	velocity = position.direction_to(target_position) * speed

	if position.distance_to(initial_position) < 5:
		velocity = Vector2.ZERO
		return
		
	if abs(velocity.x) > 10:
		animated_sprite_2d.flip_h = velocity.x > 0


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


func play_anim(name: String) -> void:
	if animated_sprite_2d.animation != name:
		animated_sprite_2d.play(name)


func _on_player_dead():
	player_is_dead = true
	velocity = Vector2.ZERO
	play_anim("idle")

		
func destroid() -> void:
	if is_dying:
		return

	# REF: musica-de-peligro
	player.start_shake(10)
	LevelManager.add_eliminated_enemy() 
	is_dying = true
	play_anim("hit")
	sfx.play()
	await get_tree().create_timer(0.5).timeout
	queue_free()
	# Ver aca que hay q controlar además si los enemigos tienen ID 1 o 2 o ambos
	if LevelManager.enemigos_eliminados == LevelManager.enemigos_totales:
		AudioManager.play_level()  #
