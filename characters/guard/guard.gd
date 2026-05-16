@tool
class_name Guard extends Node2D

@onready var body: CharacterBody2D = $CharacterBody2D
@onready var cone: VisionCone = $CharacterBody2D/VisionCone
@onready var path: Path2D = $Path2D
@onready var follow: PathFollow2D = $Path2D/PathFollow2D
@onready var sprite: CharacterSprite = $CharacterBody2D/CharacterSprite

@export_category("Mechanics")
@export var patrol_speed: float
@export var chase_speed: float
@export var catch_distance: float
@export var turn_speed: float

@export_category("Visuals")
@export var cone_color_unseen: Color:
	set(value):
		cone_color_unseen = value
		if is_node_ready():
			cone.color = value
@export var cone_color_seen: Color

var is_chasing_player: bool
var last_known_player_position: Vector2
var is_returning_to_patrol: bool

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if is_chasing_player:
		sprite.state = "run"
		chase(delta)
	elif is_returning_to_patrol:
		sprite.state = "walk"
		return_to_patrol(delta)
	else:
		sprite.state = "walk"
		patrol(delta)

## Moves towards the target and returns the remaining speed budget.
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
		face_toward_target(path[next_node_index], delta)

func face_toward_target(target: Vector2, delta: float) -> void:
	align_with_rotation((target - body.global_position).angle(), delta)

func align_with_rotation(angle: float, delta: float) -> void:
	cone.global_rotation = rotate_toward(cone.global_rotation, angle, deg_to_rad(turn_speed) * delta)
	sprite.set_direction_from_angle(angle)

func chase(delta: float) -> void:
	var target_position := cone.seen_player.global_position if cone.seen_player else last_known_player_position

	navigate_toward_target(target_position, chase_speed, delta, false)
	face_toward_target(target_position, delta)

	if cone.seen_player && body.global_position.distance_to(cone.seen_player.global_position) <= catch_distance * Game.tile_size:
		Stage.instance.game_over()
	elif !cone.seen_player && body.global_position.distance_to(last_known_player_position) < 0.01:
		is_chasing_player = false
		is_returning_to_patrol = true

func return_to_patrol(delta: float) -> void:
	navigate_toward_target(follow.global_position, patrol_speed, delta, true)

	if body.global_position.distance_to(follow.global_position) <= 0.01:
		is_returning_to_patrol = false

func patrol(delta: float) -> void:
	follow.progress += patrol_speed * Game.tile_size * delta
	body.global_position = follow.global_position
	align_with_rotation(follow.global_rotation, delta)

func _on_vision_cone_player_entered(player: Player) -> void:
	is_chasing_player = true
	cone.color = cone_color_seen

func _on_vision_cone_player_exited(player: Player) -> void:
	last_known_player_position = player.global_position
	cone.color = cone_color_unseen
