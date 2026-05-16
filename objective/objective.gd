class_name Objective extends Area2D

func _on_body_entered(body: Node2D) -> void:
	Stage.instance.objective_collected()
	queue_free()
