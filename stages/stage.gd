class_name Stage extends Node

@onready var game_over_screen: Control = $UI/GameOverScreen
@onready var alarm_screen: Control = $UI/AlarmScreen

@export_file var hideout_scene: String

static var instance: Stage

func _init() -> void:
	instance = self

func game_over() -> void:
	get_tree().paused = true
	game_over_screen.visible = true

func restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func hideout() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(hideout_scene)

func objective_collected() -> void:
	alarm_screen.visible = true
