extends Node

const START_SCENE_PATH = "res://src/start_screen/start_screen.tscn"
const GAME_SCENE_PATH = "res://src/main.tscn"

const GameDataPath = "user://conf.cfg"
var config:ConfigFile

var in_game:=false
var in_dialogue:=false
var game:Game

@onready var music_manager: MusicManager = $MusicManager
@onready var ui_sfx: UiSfx = $UiSfx


func _ready():
	_init_logger()
	
	if get_tree().current_scene.scene_file_path == GAME_SCENE_PATH:
		start_game()
	

func go_to_main_menu():
	get_tree().change_scene_to_file(START_SCENE_PATH)
	

func start_game():
	Logger.info("Starting Game")
	in_game=true
	
	music_manager.fade_menu_music()
	await get_tree().create_timer(1).timeout


	if get_tree().current_scene.scene_file_path != GAME_SCENE_PATH:
		get_tree().change_scene_to_file(GAME_SCENE_PATH)
		
	music_manager.fade_in_game_music()
	

func _init_logger():
	Logger.set_logger_level(Logger.LOG_LEVEL_INFO)
	Logger.set_logger_format(Logger.LOG_FORMAT_MORE)
	var console_appender:Appender = Logger.add_appender(ConsoleAppender.new())
	console_appender.logger_format=Logger.LOG_FORMAT_FULL
	console_appender.logger_level = Logger.LOG_LEVEL_INFO
	var file_appender:Appender = Logger.add_appender(FileAppender.new("res://debug.log"))
	file_appender.logger_format=Logger.LOG_FORMAT_FULL
	file_appender.logger_level = Logger.LOG_LEVEL_DEBUG
	Logger.info("Logger initialized.")


func do_lose():
	get_tree().quit()

func do_win():
	get_tree().quit()
	
