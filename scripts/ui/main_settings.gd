extends Control

func _ready() -> void:
	if Util.settings:
		Util.refresh_settings()
		%DFont.button_pressed = Util.settings.dyslexic_font
		%FSToggle.button_pressed = Util.settings.fullscreen
		%MuteToggle.button_pressed = Util.settings.mute
		%vol_slider.value = Util.settings.vol
		%ResolutionDD.selected = Util.settings.resolution_index
	%BackBtn.call_deferred("grab_focus")

	var margin_container: MarginContainer = self.get_node("MarginContainer")
	Util.set_margins(margin_container, 0.15, 0.1)

func _on_back_btn_pressed() -> void:
	Signals.settings_closed.emit()
	self.queue_free()

func _on_resolution_selected(index: int) -> void:
	var res: Vector3i = Util.RESOLUTIONS.get(Util.RESOLUTIONS_INDEX[index])
	DisplayServer.window_set_size(Vector2i(res.x, res.y))
	Util.settings.font_size = res.z
	Util.project_theme.default_font_size = res.z
	Util.settings.resolution_index = index
	Util.save_settings()

func _on_fs_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
		Util.settings.fullscreen = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
		Util.settings.fullscreen = false
	Util.save_settings()

func _on_vol_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
	Util.settings.vol = value
	Util.save_settings()

func _on_mute_toggled(toggled_on: bool) -> void:
		AudioServer.set_bus_mute(0, toggled_on)
		Util.settings.mute = true
		Util.save_settings()

func _on_d_font_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Util.project_theme.default_font = Util.dys_font
		Util.project_theme.default_font_size = 12
		Util.settings.dyslexic_font = true
	else:
		Util.project_theme.default_font = Util.def_font
		Util.project_theme.default_font_size = Util.settings.font_size
		Util.settings.dyslexic_font = false
	Util.save_settings()
