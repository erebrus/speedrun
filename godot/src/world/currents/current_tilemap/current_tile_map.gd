class_name CurrentTilemap extends TileMapLayer

@export var current_strength: Array[float]
@export var plankton_chance: Array[float]
@export var turn_time: float = 3.0

@export var PlanctonScene:PackedScene
@export var CurrentScene: PackedScene
@export var target_container:Node2D

var rnd := RandomNumberGenerator.new()

var current_direction = [
	Vector2i.DOWN,
	Vector2i.RIGHT,
	Vector2i.UP,
	Vector2i.LEFT
]

var show_current_arrows:
	set(value):
		show_current_arrows = value
		visible = show_current_arrows
	

var container: Node2D


var cells_by_strength: Array[Array]


func _ready():
	rnd.randomize()
	_generate_all_currents()
	Debug.show_current_arrows_toggled.connect(func(): show_current_arrows = Debug.show_current_arrows)
	show_current_arrows = Debug.show_current_arrows
	

func _generate_all_currents() -> void:
	container = Node2D.new()
	container.name = "Currents"
	
	for i in current_strength.size():
		cells_by_strength.append([])
		for j in current_direction.size():
			for o in 2:
				_generate_currents_for(i,j,o)
	
	add_sibling.call_deferred(container)
	

func _generate_currents_for(strength: int, direction: int, option: int) -> void:
	Logger.info("Generating currents in direction %s and intensity %s" % [current_direction[direction], current_strength[strength]])
	var cells = get_used_cells_by_id(0, Vector2i(strength, option), direction)
	cells_by_strength[strength].append_array(cells)
	while not cells.is_empty():
		var used_cells: Array[Vector2i]
		var seed_cell = cells.pop_front()
		_add_neighbors(seed_cell, used_cells, cells)
		var polygon = _get_cell_polygon(seed_cell)
		for cell in used_cells:
			polygon = Geometry2D.merge_polygons(polygon, _get_cell_polygon(cell)).front()
		var current: Current = CurrentScene.instantiate()
		current.intensity = current_strength[strength]
		current.direction = current_direction[direction]
		if option == 1:
			current.turn_time = turn_time
		
		current.set_polygon(polygon)
		container.add_child(current)
		Logger.info("Generated current in direction %s and intensity %s with %s cells" % [current_direction[direction], current_strength[strength], used_cells.size()])
	

func _add_neighbors(seed_cell: Vector2i, used_cells: Array[Vector2i], cells: Array[Vector2i]) -> void:
	_add_neighbor(seed_cell, TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE, used_cells, cells)
	_add_neighbor(seed_cell, TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE, used_cells, cells)
	_add_neighbor(seed_cell, TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE, used_cells, cells)
	_add_neighbor(seed_cell, TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE, used_cells, cells)
	

func _add_neighbor(seed_cell: Vector2i, neighbor: TileSet.CellNeighbor, used_cells: Array[Vector2i], cells: Array[Vector2i]) -> void:
	if cells.is_empty():
		return
	
	var cell = get_neighbor_cell(seed_cell, neighbor)
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
	

func _on_plankton_timer_timeout():
	var tile_size = tile_set.tile_size
	for strength in cells_by_strength.size():
		var cells = cells_by_strength[strength]
		var chance = plankton_chance[strength]
		var number = int(floor(chance * cells.size()))
		if rnd.randf() < (chance * cells.size() - number):
			number += 1
		
		cells.shuffle()
		for i in number:
			var cell = cells[i]
			var plancton := PlanctonScene.instantiate() as Plancton
			plancton.global_position = map_to_local(cell) + Vector2(tile_size.x * rnd.randf(), tile_size.y * rnd.randf())
			target_container.add_child(plancton)
