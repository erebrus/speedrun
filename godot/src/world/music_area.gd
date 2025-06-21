extends Area2D

@export var music_idx:int


func _on_body_entered(body: Node2D) -> void:
	Events.entered_music_area.emit(music_idx)
