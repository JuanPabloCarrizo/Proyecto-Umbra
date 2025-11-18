extends Area2D

class_name Objeto

@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D
@export var tipo: int # Podría ser String y definimos el nombre, ej: Debuff, Recuerdo, Escencia
@export var id: int
@onready var door: StaticBody2D = $"../../TileMapsLayers/Door"



func _on_body_entered(body: Node2D) -> void:
	#if body is CharacterBody2D:
	if body is Player:
		if visible == true:
			sfx.play()
			if tipo == 3: #Frenzy_mode
				body.start_shake(60.0)
				# REF: Frenzy mode
				#body.set_slow_motion(0.4)
				LevelManager.frenzy_mode = true
			elif tipo == 2:
				door.queue_free()
			elif tipo == 5: # Fin-Frenzy_mode
				LevelManager.frenzy_mode = false
			else:
				pass
				
		visible = false
		#$CollisionShape2D.disabled = true
		$CollisionShape2D.set_deferred("disabled",true)
		
	if body is Enemy:
		pass
