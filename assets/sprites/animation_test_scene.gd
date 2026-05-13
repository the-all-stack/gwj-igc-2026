extends CanvasLayer

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var character_option: OptionButton = %OptionButton
@onready var animation_option: OptionButton = %AnimationPlayed # Your second OptionButton
@onready var animation_played: OptionButton = %AnimationPlayed

# Character Resources
const CHANGE_SPRITE_FRAMES = preload("uid://bfbgc0bicrl45")
const CITIZEN_01_SPRITE_FRAMES = preload("uid://dp3135bp75j67")
const CITIZEN_02_SPRITE_FRAMES = preload("uid://dl3302s7j81cr")
const GUARD_SPRITE_FRAMES = preload("uid://b0lrlo7byiu7n")

var current_base_anim: String = "" 
var animations_data: Dictionary = {}

func _ready() -> void:
	_on_option_button_item_selected(0)

func _get_animations(sprite_frame_checked: SpriteFrames) -> Dictionary:
	var result: Dictionary = {}
	var checked_names: PackedStringArray = sprite_frame_checked.get_animation_names()
	var directions: PackedStringArray = ["n", "s", "e", "w", "ne", "nw", "se", "sw"]
	
	for anim_name: String in checked_names:
		var parts: PackedStringArray = anim_name.split("_")
		var base_name: String = anim_name
		var has_cardinal: bool = false
		
		if parts.size() > 1:
			var last_part: String = parts[parts.size() - 1].to_lower()
			if last_part in directions:
				has_cardinal = true
				var base_parts: PackedStringArray = parts.slice(0, parts.size() - 1)
				base_name = "_".join(base_parts)
		
		if result.has(base_name):
			result[base_name] = result[base_name] or has_cardinal
		else:
			result[base_name] = has_cardinal
			
	return result

func _update_animation_list() -> void:
	animation_option.clear()
	var keys: Array = animations_data.keys()
	keys.sort() # Keep it tidy
	
	for action: String in keys:
		animation_option.add_item(action)
	
	# Set current base to whatever is first in the new character's list
	if animation_option.item_count > 0:
		_on_animation_played_item_selected(0)

func _play_dir_anim(dir_suffix: String) -> void:
	if current_base_anim == "":
		return
		
	var target_anim: String = current_base_anim
	
	if animations_data.get(current_base_anim, false):
		target_anim = current_base_anim + "_" + dir_suffix
	
	if animated_sprite.sprite_frames.has_animation(target_anim):
		animated_sprite.play(target_anim)
	else:
		# Fallback if the specific variant is missing
		var names: PackedStringArray = animated_sprite.sprite_frames.get_animation_names()
		if names.size() > 0:
			animated_sprite.play(names[0])

# --- Signal Connections ---

func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			animated_sprite.set_sprite_frames(CHANGE_SPRITE_FRAMES)
		1:
			animated_sprite.set_sprite_frames(CITIZEN_01_SPRITE_FRAMES)
		2:
			animated_sprite.set_sprite_frames(CITIZEN_02_SPRITE_FRAMES)
		3:
			animated_sprite.set_sprite_frames(GUARD_SPRITE_FRAMES)
	
	animations_data = _get_animations(animated_sprite.sprite_frames)
	_update_animation_list()

func _on_animation_played_item_selected(index: int) -> void:
	current_base_anim = animation_option.get_item_text(index)
	_play_dir_anim("s") # Default to North view when action changes

# Directional Buttons
func _on_north_west_pressed() -> void: _play_dir_anim("nw")
func _on_west_pressed() -> void:       _play_dir_anim("w")
func _on_south_west_pressed() -> void: _play_dir_anim("sw")
func _on_north_pressed() -> void:      _play_dir_anim("n")
func _on_south_pressed() -> void:      _play_dir_anim("s")
func _on_north_east_pressed() -> void: _play_dir_anim("ne")
func _on_east_pressed() -> void:       _play_dir_anim("e")
func _on_south_east_pressed() -> void: _play_dir_anim("se")
