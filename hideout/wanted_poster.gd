class_name WantedPoster extends Button

@export var stage_scene: PackedScene

func _pressed() -> void:
	get_tree().change_scene_to_packed(stage_scene)
