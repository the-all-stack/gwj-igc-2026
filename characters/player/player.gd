class_name Player extends CharacterBody2D

@export_category("Speed")
@export var base_speed: float
@export var sprint_speed: float

@export_category("Stamina")
@export var max_stamina: float
@export var min_stamina_to_start_sprinting: float
@export var stamina_usage_rate: float
@export var stamina_regen_rate: float
@export var stamina_regen_delay: float

var stamina: float
var stamina_regen_delay_timer: float
var was_sprinting: bool

static var instance: Player

func _init() -> void:
	instance = self

func _ready() -> void:
	stamina = max_stamina

func _physics_process(delta: float) -> void:
	var can_sprint := stamina > 0 && (stamina > min_stamina_to_start_sprinting || was_sprinting)
	var is_sprinting := Input.is_action_pressed("sprint") && can_sprint
	was_sprinting = is_sprinting
	
	if is_sprinting:
		stamina = maxf(0, stamina - stamina_usage_rate * delta)
		stamina_regen_delay_timer = stamina_regen_delay
	elif stamina_regen_delay_timer > 0:
		stamina_regen_delay_timer = maxf(0, stamina_regen_delay_timer - delta)
	else:
		stamina = minf(max_stamina, stamina + stamina_regen_rate * delta)
	
	var speed := sprint_speed if is_sprinting else base_speed
	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * speed * Game.tile_size
	move_and_slide()
