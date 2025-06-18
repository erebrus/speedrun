extends Node2D

@export var player: Player

var start_time: int
var is_charging: bool = false

@onready var progress: TextureProgressBar = $ProgressBar


func _physics_process(_delta: float) -> void:
	rotation = -player.rotation
	progress.value = player.thrust_factor
	
	if player.thrust_factor >= player.perfect_thrust_interval.x and player.thrust_factor <= player.perfect_thrust_interval.y:
		progress.tint_progress = Color.CHARTREUSE
	else:
		progress.tint_progress = Color.WHITE
