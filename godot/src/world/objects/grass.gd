class_name Grass extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready():
	animation_player.play("default")
