extends PanelContainer


func _ready() -> void:
	hide()
	%Invulnerable.button_pressed = Debug.invulnerable
	 

func _input(event: InputEvent) -> void:
	if Debug.debug_build and event.is_action_pressed("debug"):
		if visible:
			hide()
		else:
			open()
	

func open() -> void:
	# TODO: before show logic
	show()
	

func _on_music_tension_toggle_pressed() -> void:
	if Globals.music_manager.current_game_music_id==Types.GameMusic.HARD:
		Globals.music_manager.change_game_music_to(Types.GameMusic.EASY)
	else:
		Globals.music_manager.change_game_music_to(Globals.music_manager.current_game_music_id+1)
	

func _on_invulnerable_toggled(toggled_on: bool) -> void:
	Debug.invulnerable = toggled_on
	

func _on_game_over_pressed():
	Globals.do_lose()
	

func _on_win_game_pressed():
	Globals.do_win()
	
