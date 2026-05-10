extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

var tween: Tween

@export_category("Movement")
@export var move_timer: float = 0
@export var move_interval_low: float = 5
@export var move_interval_high: float = 8
@export var move_min := Vector2(-256, -144)
@export var move_max := Vector2(256, 144)
@export var move_speed: float = 128

@export_category("Size")
@export var sprite_size: float = 512
@export var current_size: float = 0
@export var base_size: float = 128
@export var move_size: float = 64
@export var resize_length: float = 0.3

func _init() -> void:
	randomize_move_timer()
	
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "current_size", base_size, resize_length)

func _process(delta: float) -> void:
	if (move_timer > 0):
		move_timer -= delta
	else:
		move_randomly()
		randomize_move_timer()
	
	sprite.scale = current_size / sprite_size * Vector2.ONE

func move_randomly() -> void:
	if (tween):
		tween.kill()
	
	var new_position := get_random_point_in_move_bounds()
	var move_length := (new_position - position).length()
	
	tween = create_tween()
	tween.tween_property(self, "current_size", move_size, resize_length).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", new_position, move_length / move_speed).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "current_size", base_size, resize_length).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func get_random_point_in_move_bounds() -> Vector2:
	return Vector2(randf_range(move_min.x, move_max.x), randf_range(move_min.y, move_max.y))

func randomize_move_timer() -> void:
	move_timer = randf_range(move_interval_low, move_interval_high)
