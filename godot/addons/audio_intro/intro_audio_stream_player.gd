# res://addons/audio_intro/intro_audio_stream_player.gd
@tool
class_name IntroAudioStreamPlayer extends AudioStreamPlayer


@export var intro_stream: AudioStream
var _main_stream: AudioStream = null
var _playing_intro := false

func play_from_intro():
	if intro_stream:
		_main_stream = stream
		stream = intro_stream
		_playing_intro = true
		super.play()
	else:
		_playing_intro = false
		super.play(0)

func _ready():
	connect("finished", _on_stream_finished)

func _on_stream_finished():
	if _playing_intro and _main_stream:
		stream = _main_stream
		_playing_intro = false
		super.play()
