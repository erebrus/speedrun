extends Control

@export var button_press_auto_connect: bool = false

@onready var player_name: LineEdit = %PlayerName
@onready var start_sfx: AudioStreamPlayer = %StartSfx

var is_ready: bool = false

func _ready() -> void:
	Globals.in_game=false
	Globals.music_manager.fade_game_music()
	Globals.music_manager.fade_in_menu_music()
	
	player_name.text = Leaderboard.player_name
	Leaderboard.session_created.connect(_on_player_identified)
	Leaderboard.session_failed.connect(_on_session_failed)
	

func _exit_tree() -> void:
	Globals.music_manager.fade_menu_music()
	

func _on_volume_changed(_value: float) -> void:
	if not is_node_ready():
		return
	
	Globals.ui_sfx.click_sfx.play()
	

func _on_start_button_pressed() -> void:
	if not is_ready:
		return
	
	var player_name = player_name.text
	if not player_name.is_empty():
		Leaderboard.set_player_name.call_deferred(player_name)
	
	start_sfx.play()
	
	Globals.start_game()
	

func _on_player_identified() -> void:
	is_ready = true
	

func _on_session_failed() -> void:
	is_ready = true
