extends Node

signal session_created

var player_identifier: String
var player_id: String
var player_name: String

var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	
	var response = await LL_Authentication.GuestSession.new().send()
	if response.success:
		player_identifier = response.player_identifier
		player_id = response.public_uid
		if response.seen_before:
			player_name = response.player_name
		else:
			player_name = "Guest%s" % _rng.randi()
		
		session_created.emit()
	else:
		Logger.error("Login failed with reason: " + response.error_data.to_string())
	

func set_player_name(value: String) -> void:
	if value == player_name:
		return
	player_name = value
	await LL_Players.SetPlayerName.new(player_name).send() 
	

func submit_score(leaderboard: String, score: int, check_highscore: bool = false) -> SubmitResponse:
	var previous_score = null
	if check_highscore:
		var previous_response = await LL_Leaderboards.GetMemberRank.new(leaderboard, player_id).send()
		if previous_response.success:
			previous_score = previous_response.score
	
	var response = await LL_Leaderboards.SubmitScore.new(leaderboard, score, player_id).send()
	if !response.success:
		return
	
	return SubmitResponse.new(response.rank, response.score, previous_score)
	

func get_top_scores(leaderboard: String, count: int = 10) -> Array[Rank]:
	var list: Array[Rank]
	var response = await LL_Leaderboards.GetScoreList.new(leaderboard, count).send()
	if response.success:
		for i in response.items:
			list.append(Rank.new(i.player.name, i.rank, i.score))
	return list
	

class SubmitResponse extends RefCounted:
	var score: int
	var rank: int
	var is_highscore: bool
	
	func _init(_rank: int, new_score: int, old_score) -> void:
		score = new_score
		is_highscore = old_score != null and new_score > old_score
		rank = _rank
	

class Rank extends RefCounted:
	var score: int
	var rank: int
	var player_name: String
	
	func _init(_player_name: String, _rank: int, _score: int) -> void:
		player_name = _player_name
		rank = _rank
		score = _score
		
	func _to_string() -> String:
		return "#%s - %s: %s" % [rank, player_name, score]
