class_name AlarmScreen extends ColorRect

@export var start_color: Color
@export var end_color: Color
@export var color_interval: float

var tween: Tween

func _on_visibility_changed() -> void:
	if visible && !tween:
		color = start_color
		tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		tween.tween_property(self, "color", end_color, color_interval)
		tween.tween_property(self, "color", start_color, color_interval)
		tween.set_loops()
	elif !visible && tween:
		tween.kill()
