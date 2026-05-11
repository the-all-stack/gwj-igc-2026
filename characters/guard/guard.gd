extends Node2D

@onready var body: CharacterBody2D = $CharacterBody2D
@onready var cone: Node2D = $CharacterBody2D/VisionCone
@onready var path: Path2D = $Path2D
@onready var follow: PathFollow2D = $Path2D/PathFollow2D

@export var speed: float

func _physics_process(delta: float) -> void:
	follow.progress += speed * Game.tile_size * delta
	body.global_position = follow.global_position
	cone.global_rotation = follow.global_rotation
