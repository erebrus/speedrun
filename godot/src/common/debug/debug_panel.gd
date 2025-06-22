extends PanelContainer

@onready var level_selection:OptionButton = %LevelSelection
@onready var tentacle_mode:OptionButton = %TentacleMode

func _ready() -> void:
	hide()
	for music in Types.GameMusic:
		%MusicTension.add_item(music, Types.GameMusic[music])
	
	%CurrentArrows.button_pressed = Debug.show_current_arrows
	

func set_levels(levels:Array[PackedScene]):
	while level_selection.item_count>0:
		level_selection.remove_item(0)
		
	for i in levels.size():
		var level = levels[i]
		var level_name = level.resource_path.get_file().replace(".tscn", "")
		level_selection.add_item(level_name, i)
	

func _input(event: InputEvent) -> void:
	if Debug.debug_build and event.is_action_pressed("debug"):
		if visible:
			hide()
		else:
			open()
	

func open() -> void:
	if not is_instance_valid(Globals.game):
		return
	
	tentacle_mode.select(Debug.tentacle_mode)
	
	show()
	

func _on_music_tension_item_selected(index:int):
	Globals.music_manager.change_game_music_to(index)
	

func _on_restart_pressed():
	var level_idx = level_selection.selected
	var level_manager = Globals.game.level_manager
	if level_idx == -1:
		return
	if level_idx >= level_manager.levels.size():
		Logger.warn("Tried to load invalid level (idx=%d)" % level_idx)
		return
	if !Globals.in_game:
		await Globals.start_game()
		await get_tree().create_timer(0.1).timeout
		
	level_manager.load_level_by_idx(level_idx)
	

func _on_next_level_pressed():
	Events.level_ended.emit()
	

func _on_game_over_pressed():
	if Globals.in_game:
		Events.player_died.emit()
	

func _on_win_game_pressed():
	Globals.do_win()
	

func _on_current_arrows_toggled(toggled_on: bool):
	Debug.show_current_arrows = toggled_on


func _on_max_energy_pressed() -> void:
	Events.debug_max_energy.emit()


func _on_shark_pressed():
	Events.trigger_shark.emit()


func _on_tentacle_mode_item_selected(index):
	Debug.tentacle_mode = index
