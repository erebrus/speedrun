@tool
extends Node2D
@export var plancton_scene:PackedScene = preload("res://src/world/plancton/plancton.tscn")
@export var size := Vector2(1400,800):
	set(_size):
		size=_size
		refresh_shape()

@export var max_count:=100
@export var target_container:NodePath
var count = 0 
func _ready() -> void:
	refresh_shape()


func refresh_shape():
	($CollisionShape2D.shape as RectangleShape2D).size=size

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	while count < max_count:
		generate_plancton()
		

func generate_plancton():
	
	var ret := plancton_scene.instantiate() as Plancton
	ret.done.connect(func (): count -= 1)
	ret.global_position=global_position-size/2+Vector2(size.x*randf(), size.y*randf())
	get_node(target_container).add_child(ret)
	count += 1
	
