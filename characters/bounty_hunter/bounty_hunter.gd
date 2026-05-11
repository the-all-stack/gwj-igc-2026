@tool
extends Node2D

var tween: Tween

@export_category("Visuals")
@export var color: Color:
	set(value):
		color = value
		queue_redraw()

@export_category("Movement")
@export var move_timer: float
@export var move_interval_low: float
@export var move_interval_high: float
@export var move_min: Vector2
@export var move_max: Vector2
@export var move_speed: float

@export_category("Size")
@export var current_size: float:
	set(value):
		current_size = value
		queue_redraw()
@export var base_size: float:
	set(value):
		base_size = value
		queue_redraw()
@export var move_size: float
@export var resize_delay: float

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	randomize_move_timer()
	
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "current_size", base_size, resize_delay)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if move_timer > 0:
		move_timer -= delta
	else:
		move_randomly()
		randomize_move_timer()

func move_randomly() -> void:
	if tween:
		tween.kill()
	
	var new_position := get_random_point_in_move_bounds()
	var move_length := (new_position - position).length()
	
	tween = create_tween()
	tween.tween_property(self, "current_size", move_size, resize_delay).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", new_position, move_length / move_speed / Game.tile_size).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "current_size", base_size, resize_delay).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

func get_random_point_in_move_bounds() -> Vector2:
	return Vector2(randf_range(move_min.x, move_max.x), randf_range(move_min.y, move_max.y)) * Game.tile_size

func randomize_move_timer() -> void:
	move_timer = randf_range(move_interval_low, move_interval_high)

func _draw() -> void:
	if not is_node_ready():
		return

	var size := base_size if Engine.is_editor_hint() else current_size
	draw_circle(Vector2(), size * 0.5 * Game.tile_size, color)
