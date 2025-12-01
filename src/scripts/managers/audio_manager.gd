extends Node

@onready var music: AudioStreamPlayer = $Music
@onready var music_frenzy: AudioStreamPlayer = $MusicFrenzy

@export var menu_music: AudioStream
@export var level_music: AudioStream
@export var frenzy_music: AudioStream
@export var ending_bad: AudioStream
@export var ending_mid: AudioStream
@export var ending_good: AudioStream

var current_music: AudioStream = null
var looping: bool = false
var is_fading_frenzy := false


func _ready() -> void:
	#Esto es porque la pausa en final_screen no permite ejecutar nada
	# salvo la UI
	music.process_mode = Node.PROCESS_MODE_ALWAYS
	# Señal de música normal
	if not music.finished.is_connected(_on_music_finished):
		music.finished.connect(_on_music_finished)

	# Señal de música frenzy
	if not music_frenzy.finished.is_connected(_on_frenzy_finished):
		music_frenzy.finished.connect(_on_frenzy_finished)


func _play(stream: AudioStream, should_loop: bool) -> void:
	_stop_frenzy_if_needed()

	if current_music == stream:
		return

	looping = should_loop
	current_music = stream

	music.stop()
	music.stream = stream
	music.play()


func _on_music_finished() -> void:
	if looping and current_music != null:
		music.play()


func play_frenzy() -> void:
	# Si ya suena y no está saliendo, no reinicies
	if music_frenzy.playing and not is_fading_frenzy:
		return

	# Corto música normal
	current_music = null
	music.stop()

	music_frenzy.stream = frenzy_music
	music_frenzy.volume_db = 0
	music_frenzy.play()
	is_fading_frenzy = false


func _on_frenzy_finished() -> void:
	# Si terminó naturalmente y seguimos en frenzy, reinicia
	if not is_fading_frenzy:
		music_frenzy.play()


func _stop_frenzy_if_needed() -> void:
	if music_frenzy.playing and not is_fading_frenzy:
		_fade_out_frenzy()


func _fade_out_frenzy() -> void:
	is_fading_frenzy = true

	var tween := create_tween()
	tween.tween_property(music_frenzy, "volume_db", -40.0, 2.0)
	tween.finished.connect(func():
		music_frenzy.stop()
		music_frenzy.volume_db = 0
		is_fading_frenzy = false)


func play_menu(): _play(menu_music, true)
func play_level(): _play(level_music, true)
func play_ending_bad(): _play(ending_bad, false)
func play_ending_mid(): _play(ending_mid, false)
func play_ending_good(): _play(ending_good, false)
