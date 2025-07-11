extends Node

signal session_created
signal session_failed
@export var inverted = true


var player_identifier: String
var player_uid: String
var player_id: String
var player_name: String

var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	
	var response = await LL_Authentication.GuestSession.new().send()
	if response.success:
		player_identifier = response.player_identifier
		player_id = str(response.player_id)
		player_uid = response.public_uid
		
		if response.seen_before:
			player_name = response.player_name
			
		
		session_created.emit()
	else:
		Logger.error("Login failed with reason: " + response.error_data.to_string())
		

func generate_name() -> void:
	await set_player_name("Guest%s" % _rng.randi())
	

func set_player_name(value: String) -> void:
	if value == player_name:
		return
	player_name = value
	await LL_Players.SetPlayerName.new(player_name).send() 
	

func submit_score(leaderboard: String, score: int, check_highscore: bool = false) -> SubmitResponse:
	var previous_score = null
	if check_highscore:
		var previous_response = await LL_Leaderboards.GetMemberRank.new(leaderboard, player_id).send()
		if previous_response.success and previous_response.player != null:
			previous_score = previous_response.score
	
	var response = await LL_Leaderboards.SubmitScore.new(leaderboard, score, player_id).send()
	if !response.success:
		return
	
	var is_highscore = false
	if previous_score == null:
		is_highscore = true
	else:
		if inverted:
			is_highscore = previous_score > response.score
		else:
			is_highscore = previous_score < response.score
	
	return SubmitResponse.new(response.rank, score, previous_score, is_highscore)
	

func get_top_scores(leaderboard: String, count: int = 10) -> Array[Rank]:
	return await get_scores(leaderboard, 0, count)
	

func get_scores(leaderboard: String, from: int = 0, count: int = 10) -> Array[Rank]:
	var list: Array[Rank]
	var response = await LL_Leaderboards.GetScoreList.new(leaderboard, count, from - 1).send()
	if response.success:
		for i in response.items:
			list.append(Rank.new(i.player.name, i.rank, i.score))
	return list
	

class SubmitResponse extends RefCounted:
	var score: int
	var best_score: int
	var rank: int
	var is_highscore: bool
	
	func _init(_rank: int, new_score: int, previous_score: Variant, _is_highscore: bool) -> void:
		score = new_score
		best_score = new_score if _is_highscore else previous_score
		is_highscore = _is_highscore
		rank = _rank
		
	func _to_string() -> String:
		var highscore_str = ""
		if is_highscore:
			highscore_str = "HIGHSCORE"
		
		return "#%s: %s %s " % [rank, score, highscore_str]
	

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
