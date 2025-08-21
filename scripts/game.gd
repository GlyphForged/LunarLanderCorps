extends Node3D

const PAUSE_MENU = preload("res://scenes/ui/pause_menu.tscn")

func _process(_delta) -> void:
	_handle_pause_input()

func _handle_pause_input() -> void:
	if Input.is_action_just_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true
		var pause_menu = PAUSE_MENU.instantiate()
		get_tree().root.add_child(pause_menu)
