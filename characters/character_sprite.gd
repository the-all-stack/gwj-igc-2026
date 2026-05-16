class_name CharacterSprite extends AnimatedSprite2D

const directions: PackedStringArray = ["e", "se", "s", "sw", "w", "nw", "n", "ne"]

@export var state: String:
	set(value):
		var old := state
		state = value
		if old != value:
			update_animation()

@export var direction: String:
	set(value):
		var old := direction
		direction = value
		if old != value:
			update_animation()

func _ready() -> void:
	update_animation()

func set_direction_from_vector(vector: Vector2) -> void:
	if vector == Vector2.ZERO:
		return
	direction = directions[roundi(fposmod(rad_to_deg(vector.angle()), 360.0) / 45.0) % directions.size()]

func update_animation() -> void:
	play(state + "_" + direction)
