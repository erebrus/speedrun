extends TextureRect


func _ready() -> void:
	Globals.in_game=false
	Globals.music_manager.fade_in_menu_music()
	

func _exit_tree() -> void:
	Globals.music_manager.fade_menu_music()
	

func _on_volume_changed(_value: float) -> void:
	if not is_node_ready():
		return
	
	Globals.ui_sfx.click_sfx.play()
	


func _on_start_button_pressed() -> void:
	Globals.start_game()
	
