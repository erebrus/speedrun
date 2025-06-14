class_name BaseLevel extends Node

var game_state:GameState

func _ready() -> void:
	Events.level_ready.emit(self)
	

func set_state(_game_state:GameState):
	game_state = _game_state
	
