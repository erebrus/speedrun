extends PanelContainer


func _ready() -> void:
	for music in Types.GameMusic:
		%MusicTension.add_item(music, Types.GameMusic[music])	
	hide()
	 

func set_levels(levels:Array[PackedScene]):
	while %LevelSelection.item_count>0:
		%LevelSelection.remove_item(0)
		
	for i in levels.size():
		var level = levels[i]
		var level_name = level.resource_path.get_file().replace(".tscn", "")
		%LevelSelection.add_item(level_name, i)

func _input(event: InputEvent) -> void:
	if Debug.debug_build and event.is_action_pressed("debug"):
		if visible:
			hide()
		else:
			open()
	

func open() -> void:
	if not is_instance_valid(Globals.game):
		return
	
	show()
	

func _on_music_tension_item_selected(index:int):
	Globals.music_manager.change_game_music_to(index)
	

func _on_restart_pressed():
	if !Globals.in_game:
		await Globals.start_game()
		await get_tree().create_timer(0.1).timeout
	Globals.game.level_manager.load_current_level()
	

func _on_next_level_pressed():
	Events.level_ended.emit()
	

func _on_game_over_pressed():
	if Globals.in_game:
		Events.player_died.emit()
	

func _on_win_game_pressed():
	Globals.do_win()
	
