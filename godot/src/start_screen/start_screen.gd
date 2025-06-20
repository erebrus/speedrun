extends TextureRect


@onready var player_name: LineEdit = %PlayerName

func _ready() -> void:
	Globals.in_game=false
	Globals.music_manager.fade_in_menu_music()
	
	player_name.text = Leaderboard.player_name
	Leaderboard.session_created.connect(_on_player_identified)
	

func _exit_tree() -> void:
	Globals.music_manager.fade_menu_music()
	

func _on_volume_changed(_value: float) -> void:
	if not is_node_ready():
		return
	
	Globals.ui_sfx.click_sfx.play()
	

func _on_start_button_pressed() -> void:
	Leaderboard.set_player_name.call_deferred(player_name.text)
	Globals.start_game()
	

func _on_player_identified() -> void:
	player_name.text = Leaderboard.player_name
	
