extends Control


var ellapsed_time:float = 0

var on := false

@onready var label: Label = $Label


func _ready():
	Events.timer_restarted.connect(_on_restart)
	Events.timer_started.connect(func (): on = true)
	Events.timer_stopped.connect(func (): on = false)

func _on_restart():
	ellapsed_time = 0
	on = true
	
func _process(delta: float) -> void:
	if on:
		ellapsed_time+=delta
		_update_ui()


func _update_ui():
	label.text = "%.2f" % ellapsed_time
