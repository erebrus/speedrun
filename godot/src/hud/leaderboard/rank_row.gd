extends PanelContainer

var data: Leaderboard.Rank


@onready var rank: Label = %Rank
@onready var player_name: Label = %PlayerName
@onready var score: Label = %Score

func _ready() -> void:
	rank.text = "#%s" % data.rank
	player_name.text = data.player_name
	score.text = "%s" % data.score
	
