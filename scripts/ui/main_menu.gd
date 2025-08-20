extends Control

func _ready() -> void:
	%Start.grab_focus()
	$MainContainer/MainSettings.hide()

func _on_start_pressed() -> void:
	SceneChanger.change_to(Util.GAME_SCENES.GAME)

func _on_settings_pressed() -> void:
	%MMContainer.hide()
	%MuteContainer.hide()
	%BGContainer.hide()
	%MainSettings.show()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_mute_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0, toggled_on)
