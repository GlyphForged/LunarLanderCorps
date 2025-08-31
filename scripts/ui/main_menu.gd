extends Control

const MAIN_SETTINGS = preload("res://scenes/ui/main_settings.tscn")

func _ready() -> void:
	%Mute.button_pressed = Util.settings.mute
	Signals.settings_closed.connect(_on_settings_closed)
	Util.set_margins($MainContainer, 0.2, 0.15)
	%Start.grab_focus()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(Util.GAME_ID)

func _on_settings_pressed() -> void:
	%MMContainer.hide()
	%MuteContainer.hide()
	%BGContainer.hide()
	var settings := MAIN_SETTINGS.instantiate()
	get_tree().root.add_child(settings)

func _on_settings_closed() -> void:
	%MMContainer.show()
	%MuteContainer.show()
	%BGContainer.show()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_mute_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0, toggled_on)
	Util.settings.mute = toggled_on
	Util.save_settings()

func _on_mm_container_visibility_changed() -> void:
	if is_visible_in_tree():
		%Start.call_deferred("grab_focus")
