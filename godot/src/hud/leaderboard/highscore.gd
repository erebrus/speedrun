extends PanelContainer

@onready var fanfare_sfx = $FanfareSfx


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		hide()
	

func populate(result: Leaderboard.SubmitResponse) -> void:
	%Score.text = "%.2fs" % [result.score / 100.0]
	%Ranking.text = "#%s" % result.rank
	


func _on_visibility_changed():
	if visible:
		fanfare_sfx.play()
