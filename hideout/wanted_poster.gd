class_name WantedPoster extends Button

@export_file var stage_scene: String

func _pressed() -> void:
	get_tree().change_scene_to_file(stage_scene)
