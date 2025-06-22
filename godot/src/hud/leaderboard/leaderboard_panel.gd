extends MarginContainer

signal loaded
signal next_level_pressed
signal reload_level_pressed

@export var row_scene: PackedScene

@export var num_rows:= 10
@export var rows_ahead_player:= 3

var is_ready: bool = false
var is_last_level: bool = false:
	set(value):
		%NextLevelButton.visible = not is_last_level
	

@onready var top_ranks: Container = %TopRanks
@onready var bottom_ranks: Container = %Bottom
@onready var ahead_of_player: Container = %AheadOfPlayer
@onready var level_label: Label = %LevelLabel

func _ready() -> void:
	_clear()
	

func populate(level: int, leaderboard_key: String, player_rank: int) -> void:
	is_ready = false
	
	level_label.text = "#%s" % [level]
	
	if player_rank <= num_rows:
		await populate_top(leaderboard_key, num_rows, player_rank)
	else:
		await populate_top(leaderboard_key, num_rows - rows_ahead_player - 1)
		await populate_bottom(leaderboard_key, player_rank - rows_ahead_player)
		
	is_ready = true
	loaded.emit()
	

func populate_top(leaderboard_key: String, num: int, player_rank:int = -1) -> void:
	await _populate_container(top_ranks, leaderboard_key, 0, num, player_rank)
	

func populate_bottom(leaderboard_key: String, from: int) -> void:
	await _populate_container(ahead_of_player, leaderboard_key, from, rows_ahead_player + 1, from + rows_ahead_player)
	bottom_ranks.show()
	

func _populate_container(container: Container, leaderboard_key: String, from: int, num: int, player_rank: int) -> void:
	var scores = await Leaderboard.get_scores(leaderboard_key, from, num)
	Logger.info("Leaderboard retrieved: %s" % [scores])
	
	for score in scores:
		var row = row_scene.instantiate()
		row.data = score
		row.is_player = score.rank == player_rank
		container.add_child(row)
	

func _clear() -> void:
	for child in top_ranks.get_children():
		child.queue_free()
	for child in ahead_of_player.get_children():
		child.queue_free()
	bottom_ranks.hide()
	

func _on_next_level_button_pressed():
	hide()
	_clear()
	
	next_level_pressed.emit()
	

func _on_exit_button_pressed():
	Globals.go_to_main_menu()
	

func _on_repeat_level_button_pressed():
	hide()
	_clear()
	
	reload_level_pressed.emit()
