class_name Tentacle extends Node2D

const NUM_RAYCASTS = 18
const RAYCAST_LENGTH = 30 
const RAYCAST_ANGLE = 2 * PI / NUM_RAYCASTS


enum State {
	IDLE,
	MOVING,
	ATTACHED
}

enum AttachMode {
	NearestWall,
	PointAndClick,
}

@export var flip: bool

@export var player: Player:
	set(value):
		player = value
		if is_node_ready() and player != null:
			sections.back().next = player
			player.hidden.connect(hide)

@export var show_target: bool = false

var sections: Array[TentacleSection]
var tentacle_end: TentacleEnd
var built: bool
var state:= State.IDLE
var raycasts: Array[RayCast2D]
var target: Vector2


@onready var line: Line2D = $Line2D
@onready var debug_target: Node = $Target

func _ready() -> void:
	for child in $Sections.get_children():
		sections.append(child as TentacleSection)
	
	tentacle_end = sections.front()
	tentacle_end.flip = flip
	
	if player != null:
		sections.back().next = player
	
	var direction = Vector2.RIGHT * RAYCAST_LENGTH
	for i in NUM_RAYCASTS:
		var raycast = RayCast2D.new()
		raycast.enabled = false
		raycast.target_position = direction.rotated(RAYCAST_ANGLE * i)
		raycast.collision_mask = 1
		raycasts.append(raycast)
		sections.front().add_child(raycast)
	

func build() -> void:
	for i in sections.size() - 1:
		sections[i].next = sections[i+1]
	
	built = true
	

func _physics_process(_delta: float) -> void:
	if not built:
		return
	
	_update_line()
	
	if Input.is_action_just_pressed("attach"):
		_enable_raycasts(true)
	
	if Input.is_action_pressed("attach"):
		if state == State.IDLE:
			_update_target()
		elif state == State.MOVING:
			_move_to_target()
	
	if Input.is_action_just_released("attach"):
		_release()
	

func _enable_raycasts(enabled: bool) -> void:
	for raycast in raycasts:
		raycast.enabled = enabled
	

func _update_line() -> void:
	var curve = Curve2D.new()
	curve.add_point(sections.front().position)
	for i in range(1, sections.size() - 1):
		var previous = sections[i-1]
		var next = sections[i+1]
		var direction = previous.position.direction_to(next.position)
		var point_in = - direction * 2.5 
		var point_out =  direction * 2.5
		
		curve.add_point(sections[i].position, point_in, point_out)
	
	curve.add_point(sections.back().position)
	curve.bake_interval = 1
	
	line.points = curve.get_baked_points()
	

func _update_target() -> void:
	if Debug.tentacle_mode == AttachMode.NearestWall:
		_update_target_to_nearest_wall()
	else:
		_update_target_to_mouse_position()
	

func _update_target_to_nearest_wall() -> void:
	var tentacle_position = tentacle_end.global_position
	var shortest_distance = pow(RAYCAST_LENGTH + 1, 2)
	var nearest_point = Vector2.ZERO
	var collider: Node
	
	for raycast in raycasts:
		if not raycast.is_colliding():
			continue
		
		var point = raycast.get_collision_point()
		var distance = tentacle_position.distance_squared_to(point)
		if distance < shortest_distance:
			shortest_distance = distance
			collider = raycast.get_collider()
			nearest_point = point + tentacle_position.direction_to(point) * 3
			
	if nearest_point == Vector2.ZERO:
		debug_target.visible = false
	else:
		target = nearest_point
		debug_target.visible = show_target
		state = State.MOVING
	

func _update_target_to_mouse_position() -> void:
	var mouse_position = get_global_mouse_position()
	var tentacle_position = tentacle_end.global_position
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(tentacle_position, mouse_position, 1)
	var result = space_state.intersect_ray(query)
	
	if result.is_empty():
		return
	
	var distance = player.global_position.distance_squared_to(result.position)
	if distance > pow(RAYCAST_LENGTH, 2):
		return
	
	target = result.position
	debug_target.visible = show_target
	state = State.MOVING
	

func _move_to_target() -> void:
	var distance = tentacle_end.global_position.distance_squared_to(target)
	if distance < 3:
		debug_target.visible = false
		state = State.ATTACHED
		tentacle_end.freeze = true
		Logger.info("Tentacle attached")
	else:
		if distance > 30:
			_update_target()
		tentacle_end.apply_impulse(tentacle_end.global_position.direction_to(target) * 5.0)
		debug_target.global_position = target
	

func _release() -> void:
	state = State.IDLE
	_enable_raycasts(false)
	tentacle_end.freeze = false
	debug_target.hide()
	Logger.info("Tentacle dettached")
		
