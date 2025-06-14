class_name CurrentTilemap extends TileMapLayer

@export var CurrentScene: PackedScene
@export var current_strength: Array[float]

var current_direction = [
	Vector2i.DOWN,
	Vector2i.RIGHT,
	Vector2i.UP,
	Vector2i.LEFT
]


func _ready():
	self_modulate = Color.TRANSPARENT
	_generate_all_currents()

func _generate_all_currents() -> void:
	for i in current_strength.size():
		for j in current_direction.size():
			_generate_currents_for(i,j)
	

func _generate_currents_for(strength: int, direction: int) -> void:
	Logger.info("Generating currents in direction %s and intensity %s" % [current_direction[direction], current_strength[strength]])
	var cells = get_used_cells_by_id(strength, Vector2i(-1,-1), direction)
	while not cells.is_empty():
		var used_cells: Array[Vector2i]
		var seed = cells.pop_front()
		_add_neighbors(seed, used_cells, cells)
		var polygon = _get_cell_polygon(seed)
		for cell in used_cells:
			polygon = Geometry2D.merge_polygons(polygon, _get_cell_polygon(cell)).front()
		var current: Current = CurrentScene.instantiate()
		current.intensity = current_strength[strength]
		current.direction = current_direction[direction]
		current.set_polygon(polygon)
		add_child(current)
		Logger.info("Generated current in direction %s and intensity %s with %s cells" % [current_direction[direction], current_strength[strength], used_cells.size()])
	

func _add_neighbors(seed: Vector2i, used_cells: Array[Vector2i], cells: Array[Vector2i]) -> void:
	_add_neighbor(seed, TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE, used_cells, cells)
	_add_neighbor(seed, TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE, used_cells, cells)
	_add_neighbor(seed, TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE, used_cells, cells)
	_add_neighbor(seed, TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE, used_cells, cells)
	

func _add_neighbor(seed: Vector2i, neighbor: TileSet.CellNeighbor, used_cells: Array[Vector2i], cells: Array[Vector2i]) -> void:
	if cells.is_empty():
		return
	
	var cell = get_neighbor_cell(seed, neighbor)
	if cells.has(cell):
		cells.erase(cell)
		used_cells.append(cell)
		_add_neighbors(cell, used_cells, cells)
	

func _get_cell_polygon(cell: Vector2i) -> PackedVector2Array:
	var size = tile_set.tile_size
	var offset = Vector2i(cell.x * size.x, cell.y * size.y)
	var polygon = PackedVector2Array([
		offset, 
		offset + Vector2i(size.x, 0), 
		offset + size,
		offset + Vector2i(0, size.y),
	])
	return polygon
	
