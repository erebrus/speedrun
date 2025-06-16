class_name EnergyNode extends Area2D


func _on_body_entered(body: Node2D) -> void:
	body.collect(self)
	destroy()
func destroy():
	queue_free() #TODO animate
