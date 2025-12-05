extends Node

class_name Level

@export var level_id : int
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

var level_data : LevelData


func _ready() -> void:
	audio.play()
	level_data = LevelManager.get_level_by_id(level_id)
