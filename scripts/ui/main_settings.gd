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
	Util.set_margins(margin_container, 0.2, 0.15)

func _on_back_btn_pressed() -> void:
	Signals.settings_closed.emit()
	self.queue_free()

func _on_resolution_selected(index: int) -> void:
	DisplayServer.window_set_size(
		Util.RESOLUTIONS.get(Util.RESOLUTIONS_INDEX[index]
	))
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
	var project_theme: Theme = load(Util.THEME_ID)
	var def_font: FontFile = load(Util.DEF_FONT_ID)
	var dys_font: FontFile = load(Util.DYS_FONT_ID)
	if toggled_on:
		project_theme.default_font = dys_font
		project_theme.default_font_size = 12
		Util.settings.dyslexic_font = true
	else:
		project_theme.default_font = def_font
		project_theme.default_font_size = Util.settings.font_size
		Util.settings.dyslexic_font = false
	Util.save_settings()
