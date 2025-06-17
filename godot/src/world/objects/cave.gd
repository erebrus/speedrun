class_name Cave extends StaticBody2D

@onready var player_target: Marker2D = $PlayerTarget
@onready var area_2d: Area2D = $Area2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	Logger.info("Should end")
	area_2d.collision_mask=0
	collision_mask=0
	body.lose_camera()
	var tween := get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(body,"global_position",player_target.global_position,.3)
	await tween.finished
	body.visible=false
	Events.level_ended.emit()
	
