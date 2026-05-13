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

func move_toward_target(target: Vector2, speed: float, delta: float) -> void:
	var velocity_error = (target - body.global_position) / delta
	var max_speed_px = speed * Game.tile_size

	cone.global_rotation = velocity_error.angle()
	body.velocity = velocity_error.limit_length(max_speed_px)
	body.move_and_slide()

func chase(delta: float) -> void:
	var target_position := seen_player.position if seen_player else last_known_player_position

	move_toward_target(target_position, chase_speed, delta)

	if body.global_position.distance_to(target_position) <= catch_distance:
		is_chasing_player = false
		is_returning_to_patrol = true

func return_to_patrol(delta: float) -> void:
	move_toward_target(follow.global_position, patrol_speed, delta)

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
