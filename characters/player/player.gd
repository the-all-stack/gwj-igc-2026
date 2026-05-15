@tool
class_name Player extends CharacterBody2D

@onready var stamina_bar: StaminaBar = $StaminaBar

@export_category("Speed")
@export var base_speed: float
@export var sprint_speed: float

@export_category("Stamina")
@export var max_stamina: float:
	set(value):
		max_stamina = value
		update_stamina_bar()
@export var min_stamina_to_start_sprinting: float
@export var stamina_usage_rate: float
@export var stamina_regen_rate: float
@export var stamina_regen_delay: float

@export_category("Stamina Bar")
@export var stamina_bar_enabled_fill_color: Color:
	set(value):
		stamina_bar_enabled_fill_color = value
		if is_node_ready():
			stamina_bar.fill_color = value
@export var stamina_bar_disabled_fill_color: Color

var stamina: float:
	set(value):
		stamina = value
		update_stamina_bar()
var stamina_regen_delay_timer: float
var was_sprinting: bool

static var instance: Player

func _init() -> void:
	instance = self

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	stamina = max_stamina

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	var can_sprint := stamina > 0 && (stamina > min_stamina_to_start_sprinting || was_sprinting)
	stamina_bar.fill_color = stamina_bar_enabled_fill_color if can_sprint else stamina_bar_disabled_fill_color
	
	var is_sprinting := Input.is_action_pressed("sprint") && can_sprint
	was_sprinting = is_sprinting
	
	var move_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if is_sprinting && move_input != Vector2.ZERO:
		stamina = maxf(0, stamina - stamina_usage_rate * delta)
		stamina_regen_delay_timer = stamina_regen_delay
	elif stamina_regen_delay_timer > 0:
		stamina_regen_delay_timer = maxf(0, stamina_regen_delay_timer - delta)
	else:
		stamina = minf(max_stamina, stamina + stamina_regen_rate * delta)
	
	var speed := sprint_speed if is_sprinting else base_speed
	velocity = move_input * speed * Game.tile_size
	move_and_slide()

func update_stamina_bar() -> void:
	if is_node_ready():
		stamina_bar.ratio = stamina / max_stamina
