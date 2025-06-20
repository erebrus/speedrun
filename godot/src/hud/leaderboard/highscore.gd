extends PanelContainer


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		hide()
	

func populate(result: Leaderboard.SubmitResponse) -> void:
	%Score.text = "%s" % result.score
	%Ranking.text = "#%s" % result.rank
	
