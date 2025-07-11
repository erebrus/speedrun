@tool
extends Node2D


enum RotationType {
	NONE,
	ORTAGONAL,
	ANY
}

@export var textures: Array[Texture2D]:
	set(value):
		textures = value
		redraw()
	

@export var num_elements: int = 5:
	set(value):
		num_elements = value
		redraw()
	

@export var min_radius: float = 10:
	set(value):
		min_radius = value
		redraw()
	

@export var max_radius: float = 30:
	set(value):
		max_radius = value
		redraw()
	

@export var rotation_type: RotationType = RotationType.NONE:
	set(value):
		rotation_type = value
		redraw()
	
@export_tool_button("Redraw") var redraw_button = redraw


func _ready() -> void:
	redraw()
	

func redraw() -> void:
	if not Engine.is_editor_hint():
		return
	
	for child in get_children():
		child.visible = false
		child.queue_free()
	
	for _i in num_elements:
		var sprite = Sprite2D.new()
		sprite.texture = textures.pick_random()
		sprite.position = Vector2(randf_range(min_radius, max_radius), 0).rotated(randf() * 2 * PI)
		
		if rotation_type == RotationType.ORTAGONAL:
			sprite.rotation = PI / 2 * (randi() % 4)
		elif rotation_type == RotationType.ANY:
			sprite.rotation = randf() * 2 * PI
		
		add_child(sprite)
		sprite.owner = EditorInterface.get_edited_scene_root()
	
