extends PanelContainer


@export var plain_stylebox: StyleBox
@export var highlight_stylebox: StyleBox


var data: Leaderboard.Rank
var is_player: bool

@onready var rank: Label = %Rank
@onready var player_name: Label = %PlayerName
@onready var score: Label = %Score

func _ready() -> void:
	rank.text = "#%s" % data.rank
	player_name.text = data.player_name
	score.text = "%.2fs" % [data.score / 100.0]
	
	if is_player:
		add_theme_stylebox_override("panel", highlight_stylebox)
	else:
		add_theme_stylebox_override("panel", plain_stylebox)
