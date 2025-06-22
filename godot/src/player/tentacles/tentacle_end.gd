class_name TentacleEnd extends TentacleSection

var flip: bool:
	set(value):
		flip = value
		if is_node_ready():
			sprite.flip_v = flip
	

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite.flip_v = flip
	
