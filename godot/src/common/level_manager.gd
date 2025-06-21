class_name LevelManager extends Node

signal unloading_level
signal loading_level
signal level_unloaded
signal level_ready
signal game_completed

@export var levels: Array[PackedScene]
@export var level_container:Node
@export var unload_delay:=0.0
@export var override_level:PackedScene

var current_level_idx = 0
func _ready():
	assert(level_container)
	assert(levels and not levels.is_empty())

func load_first_level():
	if override_level:
		load_level(override_level)
	else:
		current_level_idx = 0
		load_current_level()
			
func load_level_by_idx(idx:int):
	if idx >=0 and idx < levels.size():
		current_level_idx = idx
		load_level(levels[current_level_idx])
	else:
		Logger.warn("Tried to load invalid level with index %d" % idx)
		
func load_level(scene:PackedScene):
	if has_loaded_level():
		unload_current_level()
	loading_level.emit()
	var level  = scene.instantiate()
	level_container.add_child(level)
	level_ready.emit()

func is_last_level()->bool:
	return current_level_idx>=levels.size()-1
	
func load_current_level():
	load_level(levels[current_level_idx])

func load_next_level():
	if is_last_level():
		game_completed.emit()
		return
		
	current_level_idx+=1
	load_level(levels[current_level_idx])
		
func has_loaded_level()->bool:
	return level_container.get_child_count() > 0

func unload_current_level():
	unloading_level.emit()
	if unload_delay > 0:
		await get_tree().create_timer(unload_delay).timeout
	GameUtils.clear_node(level_container)
	level_unloaded.emit()
		
