extends CanvasLayer

@export var debug_build: bool = true:
	set(value):
		debug_build = value
		visible = value

@export var invulnerable: bool = false:
	get:
		return debug_build and invulnerable
	

func _ready() -> void:
	%Version.text = ProjectSettings.get_setting("application/config/version")
	
