class_name PauseMenu
extends CanvasLayer

const MAIN_SETTINGS: PackedScene = preload("uid://dhls1kjj4b557")
var lander: RigidBody3D

func _ready() -> void:
	Signals.settings_closed.connect(_on_settings_closed)
	lander = get_tree().get_first_node_in_group("lander")
	%Save.disabled = lander.linear_velocity.length() > .1

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		_on_resume_pressed()

func _on_resume_pressed() -> void:
	Input.mouse_mode = Util.mouse_mode_cache
	get_tree().paused = false
	queue_free()

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	queue_free()

func _on_settings_pressed() -> void:
	self.hide()
	var settings := MAIN_SETTINGS.instantiate()
	get_tree().root.add_child(settings)

func _on_settings_closed() -> void:
	self.show()

func _on_main_menu_pressed() -> void:
	SceneChanger.change_to(Util.GAME_SCENES.MENU)
	get_tree().paused = false
	queue_free()

func _on_save_pressed() -> void:
	Signals.save_game_clicked.emit()

func _on_load_pressed() -> void:
	Signals.load_game_clicked.emit()
	_on_resume_pressed()
