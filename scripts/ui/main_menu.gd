extends Control

const MAIN_SETTINGS = preload("res://scenes/ui/main_settings.tscn")

func _ready() -> void:
	%Start.grab_focus()

func _on_start_pressed() -> void:
	SceneChanger.change_to(Util.GAME_SCENES.GAME)

func _on_settings_pressed() -> void:
	%MMContainer.hide()
	%MuteContainer.hide()
	%BGContainer.hide()
	var settings := MAIN_SETTINGS.instantiate()
	get_tree().root.add_child(settings)


func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_mute_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0, toggled_on)
