@tool
extends Node2D

@export var individual_rotation: float = 0:
	set(value):
		individual_rotation = value
		reset_children(self)
		rotate_children(self, deg_to_rad(individual_rotation))

@export var animate_speed: float = 0


func _ready() -> void:
	reset_children(self)
	rotate_children(self, deg_to_rad(individual_rotation))
	

func _physics_process(delta: float) -> void:
	if animate_speed != 0:
		rotate_children(self, animate_speed * delta)
	

func reset_children(node: Node2D) -> void:
	for child in node.get_children():
		if child is AnimatedSprite2D:
			child.rotation = 0
		else:
			reset_children(node)
	

func rotate_children(node: Node2D, value: float) -> void:
	for child in node.get_children():
		if child is AnimatedSprite2D:
			child.rotation += value
		else:
			rotate_children(node, value)
