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
	if vector != Vector2.ZERO:
		set_direction_from_angle(vector.angle())

func set_direction_from_angle(angle: float) -> void:
	direction = directions[roundi(fposmod(rad_to_deg(angle), 360.0) / 45.0) % directions.size()]

func update_animation() -> void:
	if state && direction:
		play(state + "_" + direction)
