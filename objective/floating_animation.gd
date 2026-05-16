class_name FloatingAnimation extends Node2D

@onready var original_position := position

@export var floating_strength: float
@export var floating_speed: float

var floating_progress: float

func _process(delta: float) -> void:
	floating_progress = fposmod(floating_progress + floating_speed * delta, 1.0)
	position = original_position + sin(deg_to_rad(floating_progress * 360)) * floating_strength * Vector2.UP
