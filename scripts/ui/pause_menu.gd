extends Control

const MAIN_SETTINGS = preload("uid://dhls1kjj4b557")

func _ready() -> void:
	Signals.settings_closed.connect(_on_settings_closed)

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
	self.hide()
	var settings := MAIN_SETTINGS.instantiate()
	get_tree().root.add_child(settings)

func _on_settings_closed() -> void:
	self.show()

func _on_main_menu_pressed() -> void:
	SceneChanger.change_to(Util.GAME_SCENES.MENU)
	get_tree().paused = false
	queue_free()
