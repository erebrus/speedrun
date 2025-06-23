class_name Game extends Node2D

@export var game_state:GameState

@export var leaderboard_prefix: String = "speedrunjam"

@onready var level_manager: LevelManager = $LevelManager
@onready var fade_panel: FadePanel = %FadePanel
@onready var end_sfx: AudioStreamPlayer = $OverlayLayer/end_sfx
@onready var timer = %TimerDisplay
@onready var leaderboard = %LeaderboardPanel
@onready var highscore = %Highscore

func _ready():
	Globals.game = self
	Events.level_ended.connect(_on_end_level)
	fade_panel.fade_in()
	level_manager.load_first_level()
	leaderboard.next_level_pressed.connect(_on_next_level_pressed)
	leaderboard.reload_level_pressed.connect(func():level_manager.load_current_level())
	Debug.set_levels(level_manager.levels)
	Events.player_near_end.connect(func():end_sfx.play())
	Events.player_died.connect(func():level_manager.load_current_level())	
	Events.entered_music_area.connect(_on_entered_music_area)
	

func end_level():
	fade_panel.fade_out()
	
	var level_number = level_manager.current_level_idx + 1
	var leaderboard_key = "%s%02d" % [leaderboard_prefix, level_number]
	var result = await Leaderboard.submit_score(leaderboard_key, int(timer.ellapsed_time * 100), true)
	Logger.info("Score published: %s" % result)
	
	if result == null:
		if not fade_panel.has_faded:
			await fade_panel.fade_out_completed
		_on_next_level_pressed()
		return
	
	leaderboard.is_last_level = level_manager.is_last_level()
	leaderboard.populate.call_deferred(level_number, leaderboard_key, result.rank)
	
	if not fade_panel.has_faded:
		await fade_panel.fade_out_completed
	
	if result.is_highscore:
		highscore.populate(result)
		highscore.show()
		await highscore.hidden
	
	if not leaderboard.is_ready:
		await leaderboard.loaded
	
	leaderboard.show()
	

func _on_next_level_pressed() -> void:
	if not level_manager.is_last_level():
		fade_panel.fade_in()
	level_manager.load_next_level()


func _on_end_level():
	end_level()
	


func _on_level_manager_game_completed() -> void:
	Globals.do_win()


func _on_level_manager_level_unloaded() -> void:
	pass

func get_level()->BaseLevel:
	if level_manager.has_loaded_level():
		return $Level.get_child(0)
	else:
		Logger.warn("Trying to access level, but there is none there.")
		return null
	
func _on_level_manager_level_ready() -> void:
	if level_manager.current_level_idx==1:
		game_state=load("res://src/start_state.tres")
	get_level().set_state(game_state)
	fade_panel.fade_in()
	await fade_panel.fade_in_completed
	
	Events.timer_restarted.emit()
	

func _on_entered_music_area(idx:int):
	if Globals.music_manager.current_game_music_id < idx:
		Globals.music_manager.change_game_music_to(idx, 1.5)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("restart"):
		level_manager.load_current_level()
	if Input.is_action_just_pressed("next_level") and not level_manager.is_last_level():
		level_manager.load_next_level()
