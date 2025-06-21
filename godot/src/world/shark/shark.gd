class_name Shark extends Sprite2D

@export var player: Player
@export var camera: Camera2D

@export var size = Vector2(200, 60)
@export var speed: float = 50

var target: Vector2
var direction: Vector2 = Vector2.RIGHT
var state = State.WAITING
var has_entered_screen: bool

enum State {
	WAITING,
	MOVING,
	PAUSED
}

@onready var appear_timer = %AppearTimer
@onready var desist_timer = %DesistTimer
@onready var pause_timer = %PauseTimer


func _ready() -> void:
	Events.trigger_shark.connect(appear)
	

func _physics_process(delta) -> void:
	if state != State.MOVING:
		return
	
	global_position = global_position.move_toward(target, delta * speed)
	
	if global_position == target:
		_on_target_reached()
	

func appear() -> void:
	if state != State.WAITING:
		return
	
	if randf() < 0.5:
		direction = Vector2.LEFT
		flip_h = true
	else:
		direction = Vector2.RIGHT
		flip_h = false
	
	var camera_size = get_size()
	var screen_center = camera.get_screen_center_position()
	var x = screen_center.x - (camera_size.x / 2 + 200) * direction.x
	var y = screen_center.y - camera_size.y / 2 + randf() * camera_size.y 
	
	global_position = Vector2(x,y)
	Logger.info("Spawn shark at %s" % global_position)
	
	has_entered_screen = false
	desist_timer.start()
	change_direction()
	show()
	

func get_size() -> Vector2:
	var screen_size = get_viewport_rect().size
	var camera_size = Vector2(screen_size.x / camera.zoom.x, screen_size.y / camera.zoom.y)
	return camera_size
	

func change_direction() -> void:
	var x = global_position.x + 300 * direction.x
	
	var min_y = -100
	var max_y = 100
	var diff = global_position.y - camera.get_screen_center_position().y
	if diff < 0:
		min_y = 0
	else:
		max_y = 0
	
	var y = global_position.y + randi_range(min_y, max_y)
	
	target = Vector2(x,y)
	
	state = State.MOVING
	Logger.info("Change direction to %s" % target)
	

func disappear() -> void:
	Logger.info("Shark hidden")
	state = State.WAITING
	hide()
	appear_timer.start()
	

func _on_target_reached() -> void:
	var distance = camera.get_screen_center_position().distance_squared_to(global_position) 
	var in_screen = distance < pow(400, 2)
	
	if has_entered_screen and not in_screen:
		disappear()
		return
	
	if not has_entered_screen and in_screen:
		Logger.info("Shark entered screen")
		has_entered_screen = true
	
	state = State.PAUSED
	pause_timer.start()
	

func _on_random_timer_timeout():
	appear()
	

func _on_pause_timer_timeout():
	change_direction()


func _on_desist_timer_timeout():
	if state != State.WAITING and not has_entered_screen:
		disappear()
