class_name Grass extends Area2D

@onready var sprite: AnimatedSprite2D = $Sprite2D



func _ready():
	sprite.play("default")
	sprite.frame = randi() % sprite.sprite_frames.get_frame_count("default")
	
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.on_ruffle()
	sprite.play("ruffle")
	await sprite.animation_finished
	sprite.play("default")
