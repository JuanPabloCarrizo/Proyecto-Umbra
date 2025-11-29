extends Area2D

class_name Door


var player: Node2D




func _on_body_entered(body: Node2D) -> void:
	print("BODY ENTERED DOOR")
	if body is Player:
		print("BODY ENTERED DOOR 2")
		if LevelManager.door_active == true:
			LevelManager.call_deferred("finalizar_juego")
	
