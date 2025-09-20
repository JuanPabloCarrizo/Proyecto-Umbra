extends Area2D

@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D
@export var tipo: int
@onready var door: StaticBody2D = $"../../TileMapsLayers/Door"



func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		if visible == true:
			sfx.play()
			if tipo == 3:
				body.start_shake(60.0)
				# REF: mecanica-penalidad-01
				#body.set_slow_motion(0.4)
			elif tipo == 2:
				door.queue_free()
			else:
				pass
				
		visible = false
		$CollisionShape2D.disabled = true
