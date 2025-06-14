class_name BaseLevel extends Node

@onready var currents = $CurrentTileMap


var game_state:GameState

func set_state(_game_state:GameState):
	game_state = _game_state
