class_name Guard extends Node2D

@onready var body: CharacterBody2D = $CharacterBody2D
@onready var cone: VisionCone = $CharacterBody2D/VisionCone
@onready var path: Path2D = $Path2D
@onready var follow: PathFollow2D = $Path2D/PathFollow2D

@export var patrol_speed: float
@export var patrol_snap_distance: float
@export var chase_speed: float
@export var catch_distance: float

var seen_player: Player
var is_chasing_player: bool
var last_known_player_position: Vector2
var is_returning_to_patrol: bool

func _physics_process(delta: float) -> void:
	if is_chasing_player:
		chase(delta)
	elif is_returning_to_patrol:
		return_to_patrol(delta)
	else:
		patrol(delta)

## Mvoes towards the target and returns the remaining speed budget.
func move_toward_target(target: Vector2, speed: float, delta: float) -> float:
	var velocity_error := (target - body.global_position) / delta
	var max_speed_px := speed * Game.tile_size

	body.velocity = velocity_error.limit_length(max_speed_px)
	body.move_and_slide()

	return maxf(0, max_speed_px - velocity_error.length()) / Game.tile_size

func navigate_toward_target(target: Vector2, speed: float, delta: float, face_toward_node: bool) -> void:
	var path := Navigation.create_path(body.global_position, target)

	var next_node_index := Navigation.get_next_node_index(body.global_position, path)
	var speed_budget := move_toward_target(path[next_node_index], speed, delta)
	var last_node_index := path.size() - 1

	while speed_budget > 0 && next_node_index < last_node_index:
		next_node_index += 1
		speed_budget = move_toward_target(path[next_node_index], speed_budget, delta)

	if face_toward_node:
		face_toward_target(path[next_node_index])

func face_toward_target(target: Vector2) -> void:
	cone.global_rotation = (target - body.global_position).angle()

func chase(delta: float) -> void:
	var target_position := seen_player.position if seen_player else last_known_player_position

	navigate_toward_target(target_position, chase_speed, delta, false)
	face_toward_target(target_position)

	if body.global_position.distance_to(target_position) <= catch_distance:
		is_chasing_player = false
		is_returning_to_patrol = true

func return_to_patrol(delta: float) -> void:
	navigate_toward_target(follow.global_position, patrol_speed, delta, true)

	if body.global_position.distance_to(follow.global_position) <= patrol_snap_distance:
		is_returning_to_patrol = false

func patrol(delta: float) -> void:
	follow.progress += patrol_speed * Game.tile_size * delta
	body.global_position = follow.global_position
	cone.global_rotation = follow.global_rotation

func _on_vision_cone_body_entered(body: Node2D) -> void:
	if body is Player:
		seen_player = body
		is_chasing_player = true

func _on_vision_cone_body_exited(body: Node2D) -> void:
	if body is Player:
		seen_player = null
		last_known_player_position = body.global_position
