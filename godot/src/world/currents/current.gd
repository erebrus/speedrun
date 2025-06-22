class_name Current extends Area2D

enum Type {
	Static,
	Flip,
	RotateCW,
	RotateCCW
}

@export var direction:Vector2 = Vector2.DOWN
@export var intensity:float = 10

@onready var timer: Timer = $Timer

var type: Type = Type.Static
var turn_time: float = 0.0


func set_polygon(polygon: PackedVector2Array) -> void:
	$CollisionShape2D.polygon = polygon
	

func _ready():
	if type != Type.Static:
		timer.wait_time = turn_time
		timer.start()
	

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var list = get_overlapping_bodies()
	for body in list:
		if body is Player and (body as Player).in_animation:
			continue
		if body is RigidBody2D:
			body.apply_force(direction*intensity*body.mass)
			


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.currents += 1


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		body.currents -= 1


func _on_timer_timeout():
	if type == Type.Flip:
		direction = -direction
	if type == Type.RotateCW:
		direction = direction.rotated(PI/2)
	if type == Type.RotateCCW:
		direction = direction.rotated(-PI/2)
