class_name EnergyBar extends Control
@onready var progress_bar: TextureProgressBar = $ProgressBar

var max_energy:int:
	set(v):
		$ProgressBar.max_value = float(v)
	get:
		return $ProgressBar.max_value
		
func _ready():
	_on_player_energy_changed(0)
	Events.player_energy_changed.connect(_on_player_energy_changed)
	Events.player_max_energy_changed.connect(func(v): max_energy = v)

func _on_player_energy_changed(energy):
	progress_bar.value=energy
	
