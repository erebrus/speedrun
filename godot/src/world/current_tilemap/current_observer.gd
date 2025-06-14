extends Node2D

signal entered
signal exited

@export var target: Node2D

var tilemap: TileMapLayer:
	get():
		if tilemap == null:
			tilemap = Globals.level.currents
		return tilemap

var in_current: bool:
	set(value):
		if value == in_current:
			return
		in_current = value
		if in_current:
			entered.emit()
		else:
			exited.emit()
	

func _physics_process(_delta: float) -> void:
	var tile = tilemap.local_to_map(global_position)
	var tile_data = tilemap.get_cell_tile_data(tile)
	if tile_data == null:
		in_current = false
		return
	
	in_current = true
	
	if target is Player and (target as Player).in_animation:
		return
	
	var direction = tile_data.get_custom_data("direction")
	var intensity = tile_data.get_custom_data("intensity")
	var force = direction*intensity*target.mass
	
	target.apply_force(direction*intensity*target.mass)
	
