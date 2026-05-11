@tool
class_name VisionCone extends Node2D

@onready var collision: CollisionPolygon2D = $Area2D/CollisionPolygon2D

@export var color: Color:
	set(value):
		color = value
		queue_redraw()
@export_range(0, 360) var angle: float:
	set(value):
		angle = value
		queue_redraw()
@export var radius: float:
	set(value):
		radius = value
		queue_redraw()
@export_range(1, 50) var pixels_per_point: int = 10:
	set(value):
		pixels_per_point = value
		queue_redraw()

func _draw() -> void:
	if not is_node_ready():
		return
	
	var angle_rad := deg_to_rad(angle)
	var radius_px := radius * Game.tile_size
	var arc_length := angle * radius
	
	var points := PackedVector2Array()
	points.resize(3 + arc_length / max(pixels_per_point, 1))
	for i in range(1, points.size()):
		var progress := (float)(i - 1) / (points.size() - 2)
		points[i] = Vector2.from_angle(lerp(-angle_rad * 0.5, angle_rad * 0.5, progress)) * radius_px
	
	collision.polygon = points
	draw_colored_polygon(points, color)
