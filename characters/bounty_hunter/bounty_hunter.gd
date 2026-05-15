@tool
class_name BountyHunter extends Node2D

@export_category("Visuals")
@export var color: Color:
	set(value):
		color = value
		queue_redraw()

@export_category("Movement")
var move_timer: float
@export var move_interval_low: float
@export var move_interval_high: float
@export var move_bounds: Rect2
@export var move_speed: float
var move_tween: Tween

@export_category("Size")
var current_size: float
@export var base_size_static: float:
	set(value):
		base_size_static = value
		queue_redraw()
@export var base_size_moving: float
@export var size_mod_per_civilian: float
@export var size_mod_min: float
@export var size_change_rate: float
@export var size_change_curve_size: float

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	reset_move_timer()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	move_timer -= delta
	if move_timer <= 0:
		move_randomly()
		reset_move_timer()
	
	var civilians_nearby := 0
	for civilian: Civilian in get_tree().get_nodes_in_group("civilians"):
		if global_position.distance_to(civilian.global_position) <= base_size_static * Game.tile_size * 0.5:
			civilians_nearby += 1
	
	if global_position.distance_to(Player.instance.global_position) <= current_size * Game.tile_size * 0.5:
		Stage.instance.game_over()
	
	var base_size := base_size_moving if move_tween && move_tween.is_running() else base_size_static
	var size_mod := maxf(size_mod_min, 1 - civilians_nearby * size_mod_per_civilian)
	var target_size := base_size * size_mod
	current_size = Easing.easeOutCubicDelta(current_size, target_size, size_change_curve_size, size_change_rate * delta)
	queue_redraw()

func _draw() -> void:
	var size := current_size if !Engine.is_editor_hint() else base_size_static
	draw_circle(Vector2(), size * Game.tile_size * 0.5, color)

func reset_move_timer() -> void:
	move_timer = randf_range(move_interval_low, move_interval_high)

func move_randomly() -> void:
	var new_position := Vector2(randf_range(move_bounds.position.x, move_bounds.end.x), randf_range(move_bounds.position.y, move_bounds.end.y)) * Game.tile_size
	var move_distance := position.distance_to(new_position)
	if move_tween:
		move_tween.kill()
	move_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	move_tween.tween_property(self, "position", new_position, move_distance / (move_speed * Game.tile_size))
