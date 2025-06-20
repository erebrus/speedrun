class_name EnergyNode extends Area2D

@export 
var energy := 10
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collect_sfx: AudioStreamPlayer2D = $collect_sfx

func _ready() -> void:
	animation_player.play("default")
	
func _on_body_entered(body: Node2D) -> void:
	body.collect(self.energy)
	destroy()

func destroy():
	collect_sfx.play()
	visible = false
	await collect_sfx.finished
	queue_free() #TODO animate
