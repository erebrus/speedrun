extends CanvasLayer

signal show_current_arrows_toggled
signal tentacle_mode_changed(mode: Tentacle.AttachMode)

@export var debug_build: bool = true:
	set(value):
		debug_build = value
		visible = value

@export var invulnerable: bool = false:
	get:
		return debug_build and invulnerable
	
@export var show_current_arrows: bool = false:
	get:
		return debug_build and show_current_arrows
	set(value):
		if value != show_current_arrows:
			show_current_arrows = value
			show_current_arrows_toggled.emit()
	

@export var tentacle_mode: Tentacle.AttachMode = Tentacle.AttachMode.PointAndClick:
	set(value):
		if value != tentacle_mode:
			tentacle_mode = value
			tentacle_mode_changed.emit(tentacle_mode)
	

func _ready() -> void:
	%Version.text = ProjectSettings.get_setting("application/config/version")
	
func set_levels(levels:Array[PackedScene]):
	$MarginContainer/DebugPanel.set_levels(levels)
