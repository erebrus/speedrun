extends StaticBody2D

@export var closed_time:float = 10
@export var open_time:float = 10


@onready var close_timer: Timer = $CloseTimer
@onready var open_timer: Timer = $OpenTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	close_timer.wait_time = closed_time
	open_timer.wait_time = open_time
	
func _on_close_timer_timeout() -> void:
	animation_player.play("close")
	await animation_player.animation_finished
	animation_player.play("idle_close")
	open_timer.start()


func _on_open_timer_timeout() -> void:
	animation_player.play("open")
	await animation_player.animation_finished
	animation_player.play("idle_open")
	close_timer.start()
