# res://addons/audio_intro/intro_audio_stream_player.gd
@tool
class_name IntroAudioStreamPlayer extends AudioStreamPlayer


@export var intro_stream: AudioStream
var _intro_player: AudioStreamPlayer
var _main_stream: AudioStream = null
var _playing_intro := false

func play_from_intro():
	if intro_stream:
		_intro_player.play()
		_playing_intro = true
	else:
		_playing_intro = false
		super.play(0)

func _ready():
	_intro_player = AudioStreamPlayer.new()
	_intro_player.bus = bus
	_intro_player.stream = intro_stream
	_intro_player.finished.connect(_on_stream_finished)
	add_child(_intro_player)
	

func _on_stream_finished():
	if _playing_intro:
		_playing_intro = false
		super.play()
