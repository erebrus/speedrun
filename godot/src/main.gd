class_name Game extends Node2D

@export var game_state:GameState


@onready var level_manager: LevelManager = $LevelManager
@onready var fade_panel: FadePanel = %FadePanel

func _ready():
	Globals.game = self
	Events.level_ended.connect(_on_end_level)
	fade_panel.fade_in()
	level_manager.load_first_level()
	Debug.set_levels(level_manager.levels)

func _on_end_level():
	fade_panel.fade_out()
	await fade_panel.fade_out_completed
	if not level_manager.is_last_level():
		fade_panel.fade_in()

	


func _on_level_manager_game_completed() -> void:
	Globals.do_win()


func _on_level_manager_level_unloaded() -> void:
	pass

func get_level()->BaseLevel:
	if level_manager.has_loaded_level():
		return $Level.get_child(0)
	else:
		Logger.warn("Trying to access level, but there is none there.")
		return null
	
func _on_level_manager_level_ready() -> void:
	if level_manager.current_level_idx==1:
		game_state=load("res://src/start_state.tres")
	get_level().set_state(game_state)
	Events.timer_restarted.emit()
	
