class_name EnergyNode extends Area2D

@export 
var energy := 10
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("default")
	
func _on_body_entered(body: Node2D) -> void:
	body.collect(self)
	destroy()
func destroy():
	queue_free() #TODO animate
