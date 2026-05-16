class_name Civilian extends CharacterBody2D

@onready var sprite: CharacterSprite = $CharacterSprite

@export var varieties: Array[SpriteFrames]
@export var max_shift: float

func _ready() -> void:
	sprite.sprite_frames = varieties[randi_range(0, varieties.size() - 1)]
	sprite.direction = sprite.directions[randi_range(0, sprite.directions.size() - 1)]
	move_and_collide(Vector2(randf_range(0, max_shift), randf_range(0, max_shift)) * Game.tile_size)
