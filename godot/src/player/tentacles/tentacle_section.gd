class_name TentacleSection extends RigidBody2D

@export var next: RigidBody2D:
	set(value):
		next = value
		if is_node_ready() and next != null:
			joint.node_b = next.get_path()
	

@onready var joint = $PinJoint2D

func _ready() -> void:
	if next != null:
		joint.node_b = next.get_path()
