extends Control

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		_on_resume_pressed()

func _on_resume_pressed() -> void:
	get_tree().paused = false
	queue_free()

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()
	get_tree().paused = false
	queue_free()

func _on_settings_pressed() -> void:
	pass # Replace with function body.

func _on_main_menu_pressed() -> void:
	SceneChanger.change_to(Util.GAME_SCENES.MENU)
	get_tree().paused = false
	queue_free()
