extends Control

@onready var start: Button = $MainContainer/MMContainer/Start
@onready var settings: Button = $MainContainer/MMContainer/Settings
@onready var quit: Button = $MainContainer/MMContainer/Quit


func _ready() -> void:
	start.grab_focus()
	$MainContainer/MainSettings.hide()

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_settings_pressed() -> void:
	$MainContainer/MMContainer.hide()
	$MainContainer/MainSettings.show()
	$MuteContainer.hide()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_mute_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0, toggled_on)
