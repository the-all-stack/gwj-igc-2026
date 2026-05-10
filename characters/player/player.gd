extends CharacterBody2D

@export var speed: float

func _physics_process(_delta: float) -> void:
	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * speed * Game.tile_size
	move_and_slide()
