extends CharacterBody2D
class_name Player

@onready var sfx: AudioStreamPlayer = $AudioStreamPlayer
@onready var sfx_low_life: AudioStreamPlayer2D = $LowLife
@onready var camera: Camera2D = $Camera2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -550.0
const DASH_SPEED = 600.0
const DASH_DURATION = 0.4

var is_dashing := false
var dash_timer := 0.0
var can_double_jump := true
var shake: float = 0.0



#REF Sistema de vida
@export var vida_max: int = 6
var vida: int = vida_max
var vida_invencible: bool = false
@export var tiempo_invencible: float = 1.2
var muerto = false
var en_hit: bool = false
signal player_dead #esto es para que los enemigos dejen de perseguir



func _ready() -> void:
	play_anim("idle")


func _process(delta: float) -> void:
	# Sacudida de cámara
	if shake > 0:
		camera.offset = Vector2(
			randf_range(-shake, shake),
			randf_range(-shake, shake)
		)
		shake = lerp(shake, 0.0, 4 * delta)
	else:
		camera.offset = Vector2.ZERO


func start_shake(intensity: float) -> void:
	shake = intensity


func _physics_process(delta: float) -> void:
	var on_floor := is_on_floor()
	var direction := Input.get_axis("move_left", "move_right")
	
	if Input.is_action_just_pressed("dash") and not is_dashing:
		start_dash(direction)
	
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	
	if not is_on_floor() and not is_dashing:
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept"):
		if on_floor:
			velocity.y = JUMP_VELOCITY
			can_double_jump = true
			#sfx.stop()
			sfx.stream = preload("res://_assets/music/player_jump_01.wav")
			sfx.play()
			play_anim("jump")
		elif can_double_jump:
			velocity.y = JUMP_VELOCITY
			can_double_jump = false
			#sfx.stop()
			sfx.stream = preload("res://_assets/music/player_jump_01.wav")
			sfx.play()
			play_anim("jump")
	
	if not is_dashing and not en_hit:
		if direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if direction != 0:
		animated_sprite_2d.flip_h = direction < 0
	
	# Actualiza animación solo si no está en hit
	if not en_hit:
		update_animation(on_floor, direction)
	
	move_and_slide()


func start_dash(direction: float) -> void:
	if direction == 0:
		return
	
	is_dashing = true
	dash_timer = DASH_DURATION
	velocity.x = direction * DASH_SPEED
	velocity.y = 0
	sfx.stream = preload("res://_assets/music/player_dash_01.wav")
	sfx.play()
	play_anim("dash")


func play_anim(name: String) -> void:
	if animated_sprite_2d.animation != name:
		animated_sprite_2d.play(name)


func update_animation(on_floor: bool, direction: float) -> void:
	if is_dashing:
		play_anim("dash")
	elif not on_floor:
		play_anim("jump")
	elif abs(velocity.x) > 10:
		play_anim("moving")
	else:
		play_anim("idle")


# REF sistema-de-vida
#func recibe_daño(cantidad: int) -> void:
	#if muerto:
		#return
	#if vida_invencible:
		#return
#
	#vida -= cantidad
	#
		## Actualizacmos el UI ESCENCIA
	#var hud = get_parent().get_node("UI Escencia")
	#hud.actualizar_escencia(vida)
	#
	#if vida <= 0:
		#vida = 0
		#morir()
		#return
#
	#var vel_backup = velocity
	#velocity = Vector2.ZERO
	#en_hit = true
#
	#start_shake(5)
	##sfx.stop()
	#sfx.stream = preload("res://_assets/music/player_hit_01.wav")
	#sfx.play()
	#play_anim("hit")
#
	#await get_tree().create_timer(0.2).timeout
	#en_hit = false
#
	#velocity = vel_backup
#
	#vida_invencible = true
	#await get_tree().create_timer(tiempo_invencible).timeout
	#vida_invencible = false
#
	#if vida == 1:
		#print("PLAYER: le queda 1 VIDA")
		##sfx.stream = preload("res://_assets/music/player_low_life_01.wav")
		#sfx_low_life.play()
	#elif vida == 0:
		#morir()
		#return

func recibe_daño(cantidad: int) -> void:
	if muerto or vida_invencible:
		return

	vida -= cantidad

	# Actualizamos UI
	var hud = get_parent().get_node("UI Escencia")
	hud.actualizar_escencia(vida)

	# Low life suena INMEDIATO
	if vida == 1:
		print("PLAYER: le queda 1 VIDA")
		sfx_low_life.play()

	if vida <= 0:
		vida = 0
		morir()
		return

	# --- todo lo de hit y tiempos después ---
	var vel_backup = velocity
	velocity = Vector2.ZERO
	en_hit = true

	start_shake(5)
	sfx.stream = preload("res://_assets/music/player_hit_01.wav")
	sfx.play()
	play_anim("hit")

	await get_tree().create_timer(0.2).timeout
	en_hit = false
	velocity = vel_backup

	vida_invencible = true
	await get_tree().create_timer(tiempo_invencible).timeout
	vida_invencible = false


func morir() -> void:
	muerto = true
	emit_signal("player_dead")
	LevelManager.frenzy_mode = false
	play_anim("hit") #cambiarla por ("morir")	
	$CollisionShape2D.set_deferred("disabled",true)
	set_physics_process(false)
	await get_tree().create_timer(1.5).timeout
	LevelManager.cargar_final("player_muere")
