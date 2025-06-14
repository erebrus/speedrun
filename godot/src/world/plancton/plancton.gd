class_name Plancton extends RigidBody2D

signal done
@onready var random_timer: RandomTimer = $RandomTimer

func _on_random_timer_timeout() -> void:
	done.emit()
	queue_free()
	
func _ready() -> void:
	#await get_tree().process_frame
	start()
func start():
	random_timer.start()
