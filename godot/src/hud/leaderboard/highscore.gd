extends MarginContainer

@onready var fanfare_sfx = $FanfareSfx

var is_highscore: bool


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		hide()
	

func populate(result: Leaderboard.SubmitResponse) -> void:
	%Score.text = "%.2fs" % [result.score / 100.0]
	%BestScore.text = "%.2fs" % [result.best_score / 100.0]
	%Ranking.text = "#%s" % result.rank
	is_highscore = result.is_highscore
	if is_highscore:
		%Title.text = "Highscore!"
	else:
		%Title.text = "Swim Faster!"


func _on_visibility_changed():
	if visible and is_highscore:
		fanfare_sfx.play()
