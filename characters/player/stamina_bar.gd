@tool
class_name StaminaBar extends Node2D

@export var rect: Rect2:
	set(value):
		if (rect != value):
			queue_redraw()
		rect = value
@export var base_color: Color:
	set(value):
		if (base_color != value):
			queue_redraw()
		base_color = value
@export var fill_color: Color:
	set(value):
		if (fill_color != value):
			queue_redraw()
		fill_color = value

var ratio: float = 1:
	set(value):
		if (ratio != value):
			queue_redraw()
		ratio = value

func _draw() -> void:
	if !is_node_ready() || (!Engine.is_editor_hint() && ratio >= 1):
		return
	
	var base_rect := rect
	base_rect.position -= base_rect.size * 0.5
	var fill_rect := base_rect.grow_side(SIDE_RIGHT, -base_rect.size.x * (1 - clampf(ratio, 0, 1)))
	
	draw_rect(base_rect, base_color)
	draw_rect(fill_rect, fill_color)
