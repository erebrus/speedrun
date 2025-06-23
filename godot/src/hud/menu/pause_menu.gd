extends PanelContainer


@export var level_manager: LevelManager


func _ready() -> void:
	%NextLevelButton.visible = not level_manager.is_last_level()
	

func _input(event: InputEvent) -> void:
	if event.is_action_released("pause"):
		if visible:
			resume()
		else:
			pause()
	

func pause() -> void:
	get_tree().paused = true
	show()
	
func resume() -> void:
	hide()
	get_tree().paused = false
	

func _on_exit_button_pressed():
	resume()
	Globals.go_to_credits()


func _on_resume_button_pressed():
	resume()


func _on_repeat_level_button_pressed():
	resume()
	level_manager.load_current_level()


func _on_next_level_button_pressed():
	resume()
	level_manager.load_next_level()

func _on_volume_changed(_value: float) -> void:
	if not is_node_ready():
		return
	
	Globals.ui_sfx.click_sfx.play()
