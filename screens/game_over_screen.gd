extends Control

func _on_restart_button_pressed() -> void:
	Stage.instance.restart()

func _on_hideout_button_pressed() -> void:
	Stage.instance.hideout()
