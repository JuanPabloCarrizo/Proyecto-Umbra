extends Area2D

class_name Door

var player: Node2D


func _on_body_entered(body: Node2D) -> void:

	if body is Player:
		if LevelManager.door_active == true:
			print("DOOOR")
			body.velocity = Vector2.ZERO
			body.set_physics_process(false)
			body.set_process(false)
			body.set_process_input(false)
			body.play_anim("hit")
			#await get_tree().create_timer(1).timeout
			LevelManager.call_deferred("finalizar_juego")
	
