extends Control

var is_ready = false

func _ready():
	get_tree().create_timer(1).timeout.connect(func(): is_ready = true)
	

func _input(event: InputEvent):
	if not is_ready:
		return
	
	if event is InputEventKey or event is InputEventMouseButton:
		Globals.go_to_main_menu()
	
