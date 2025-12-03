extends Area2D

@onready var dialog: Sprite2D = $Dialog
const NPC_01_DIALOGUE_01 = preload("res://dialogues/npc_01_dialogue_01.dialogue")
var is_player_close = false
var is_dialogue_active = false
@onready var panel: Panel = $Panel
var panel_visible = false

func _ready() -> void:
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _process(_delta: float) -> void:
	if is_player_close and Input.is_action_just_pressed("interact") and is_dialogue_active == false:
		DialogueManager.show_dialogue_balloon(NPC_01_DIALOGUE_01,"start")
		
	#if is_dialogue_active and Input.is_action_just_pressed("cancel"):
		#DialogueManager.close_dialogue()
 


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		dialog.visible = true
		is_player_close = true
		await get_tree().create_timer(2).timeout
		show_tooltip()


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		dialog.visible = false
		is_player_close = false


func _on_dialogue_started(_dialogue):
	LevelManager.input_locked = true
	is_dialogue_active = true
	panel_visible = false
	panel.visible = false


func _on_dialogue_ended(_dialogue):
	LevelManager.input_locked = false
	dialog.visible = false
	await  get_tree().create_timer(2).timeout
	is_dialogue_active = false


func show_tooltip() -> void:

	if !panel_visible:
		panel.visible = true
		panel_visible = true
		await get_tree().create_timer(2.5).timeout
		panel_visible = false
		panel.visible = false
