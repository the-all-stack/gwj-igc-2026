@tool
class_name VisionCone extends Node2D

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
@export_range(0.1, 360, 0.1) var degrees_per_point: float = 1:
	set(value):
		degrees_per_point = value
		queue_redraw()

var seen_player: Player
signal player_entered(player: Player)
signal player_exited(player: Player)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	var old_seen_player := seen_player
	seen_player = get_seen_player()
	
	if !old_seen_player && seen_player:
		player_entered.emit(seen_player)
	elif old_seen_player && !seen_player:
		player_exited.emit(old_seen_player)

func get_seen_player() -> Player:
	var player := Player.instance
	var dist_to_player := global_position.distance_to(player.global_position)
	
	if dist_to_player > radius * Game.tile_size:
		return null
	
	var dir_to_player := global_position.direction_to(player.global_position)
	var cone_forward := global_transform.x.normalized()
	
	if dir_to_player.dot(cone_forward) < cos(angle * 0.5):
		return null
	
	var space_state := get_world_2d().direct_space_state
	var ray_query := PhysicsRayQueryParameters2D.create(global_position, player.global_position, Physics.Layers.Map)
	var ray_result := space_state.intersect_ray(ray_query)
	
	if !ray_result.is_empty():
		return null
	
	return player

func _draw() -> void:
	if not is_node_ready():
		return
	
	var angle_rad := deg_to_rad(angle)
	var radius_px := radius * Game.tile_size
	
	var points := PackedVector2Array()
	points.resize(3 + roundi(angle / maxf(degrees_per_point, 0.1)))
	for i in range(1, points.size()):
		var progress := (float)(i - 1) / (points.size() - 2)
		points[i] = Vector2.from_angle(lerpf(-angle_rad * 0.5, angle_rad * 0.5, progress)) * radius_px
	
	draw_colored_polygon(points, color)
