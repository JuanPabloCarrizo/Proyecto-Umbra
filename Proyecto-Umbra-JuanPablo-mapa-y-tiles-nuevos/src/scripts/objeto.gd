extends Area2D
class_name Objeto

@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D
@export var tipo: int # 2=Manija | 3=Frenzy On | 4=Farol | 5=Frenzy Off | etc.
@export var id: int
# REF: sistema-farol-enemigo
@onready var farol_off: Sprite2D = $Sprite2D
@onready var farol_on: Sprite2D = get_node_or_null("farol_on")
@onready var hitbox: Area2D = get_node_or_null("Hitbox") # Solo existe en escenas heredadas
@onready var farol_light: PointLight2D = get_node_or_null("Hitbox/PointLight2D")
# REF: contador-de-recuerdos y abrir-puerta
@onready var manija: Sprite2D = $Sprite2D
var manija_bool = false
@onready var puerta: Sprite2D = $"../../TileMapsLayers/Door/Sprite2D"
var farol: bool = false # Estado inicial del farol apagado
var enemies_in_range: Array=[]


# REF: sistema-farol-enemigo
func _ready() -> void:
	# Conectar hitbox opcionalmente (solo si existe)
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player and visible:
		sfx.play()

		match tipo:
			1: # Recuerdos
				body.start_shake(5)
				LevelManager.agregar_recuerdo()
				#queue_free()

			2: # Abrir Puerta - manija
				body.start_shake(10)
				manija_on_off()
				return

			3: # Frenzy Mode ON
				body.start_shake(60.0)
				LevelManager.frenzy_mode = true

			4: # Farol On/Off
				farol_on_off()
				return  # REF: sistema-farol-enemigo

			5: # Frenzy Mode OFF
				LevelManager.frenzy_mode = false

		# Para los demás tipos sí se oculta
		visible = false
		$CollisionShape2D.set_deferred("disabled", true)


# REF: sistema-farol-enemigo
func farol_on_off() -> void:
	farol = !farol  # toggle rápido

	if farol:
		farol_off.visible = false
		if farol_on:
			farol_on.visible = true
			farol_light.visible = true
		#Esto es para que elimine los enemigos que ya están en el area al activar el farol
		for enemy in enemies_in_range:
			if enemy and enemy.is_inside_tree():
				enemy.destroid()
	else:
		farol_off.visible = true
		if farol_on:
			farol_on.visible = false
			farol_light.visible = false


# REF: sistema-farol-enemigo
func _on_hitbox_body_entered(body: Node2D) -> void:
	#esto es para que elimine los enemigos que entran en el area
	if body is Enemy:
		#print("Enemigo detectado. Farol =", farol)
		enemies_in_range.append(body)

		if farol:  # Solo destruye si el farol está encendido
			body.destroid()


# REF contador-de-recuerdos y manija-on-off
func manija_on_off()-> void:
	if manija_bool == false:
		#se acitva la manija y se abre la puerta
		manija.flip_h = true
		manija_bool = true
		puerta.visible = false
		LevelManager.door_active = true
	else:
		#se desactiva la manija y se cierra la puerta
		manija.flip_h = false
		manija_bool = false
		puerta.visible = true
		LevelManager.door_active = false
