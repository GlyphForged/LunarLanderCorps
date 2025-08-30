class_name MainSettings extends Control

@export_group("Nodes")
# We assign the nodes in editor for performance and ease of updates
@export var master_vol_label: Label
@export var master_vol_slider: HSlider
@export var music_vol_label: Label
@export var music_vol_slider: HSlider
@export var game_vol_label: Label
@export var game_vol_slider: HSlider
@export var d_font_toggle: CheckButton
@export var fs_toggle: CheckButton
@export var mute_toggle: CheckButton
@export var resolution_dropdown: OptionButton
@export var back_btn: Button

enum VOLUME_SLIDER_BUS { MASTER, MUSIC, GAME }

func _ready() -> void:
	master_vol_slider.value_changed.connect(_on_master_vol_slider_value_changed)
	music_vol_slider.value_changed.connect(_on_music_vol_slider_value_changed)
	game_vol_slider.value_changed.connect(_on_game_vol_slider_value_changed)
	if Util.settings:
		Util.refresh_settings()
		d_font_toggle.button_pressed = Util.settings.dyslexic_font
		fs_toggle.button_pressed = Util.settings.fullscreen
		mute_toggle.button_pressed = Util.settings.mute
		master_vol_slider.value = Util.settings.master_vol
		music_vol_slider.value = Util.settings.music_vol
		game_vol_slider.value = Util.settings.game_vol
		resolution_dropdown.selected = Util.settings.windowed_resolution_index
		_update_volume_value(VOLUME_SLIDER_BUS.MASTER, Util.settings.master_vol)
		_update_volume_label(VOLUME_SLIDER_BUS.MASTER, Util.settings.master_vol)
		_update_volume_value(VOLUME_SLIDER_BUS.MUSIC, Util.settings.music_vol)
		_update_volume_label(VOLUME_SLIDER_BUS.MUSIC, Util.settings.music_vol)
		_update_volume_value(VOLUME_SLIDER_BUS.GAME, Util.settings.game_vol)
		_update_volume_label(VOLUME_SLIDER_BUS.GAME, Util.settings.game_vol)

	resolution_dropdown.disabled = DisplayServer.window_get_mode(0) > 3
	back_btn.call_deferred("grab_focus")

func _process(_delta) -> void:
	if Input.is_action_just_pressed("pause"):
		_on_back_btn_pressed()

func _on_back_btn_pressed() -> void:
	Signals.settings_closed.emit()
	self.queue_free()

func _on_resolution_selected(index: int) -> void:
	if DisplayServer.window_get_mode(0) < 3:
		Util.settings.windowed_resolution_index = index
	var res: Vector3i = Util.RESOLUTIONS.get(Util.RESOLUTIONS_INDEX[index])
	DisplayServer.window_set_size(Vector2i(res.x, res.y))
	Util.settings.font_size = res.z
	_set_font_size(res)
	Util.save_settings()

func _on_fs_toggled(toggled_on: bool) -> void:
	if toggled_on:
		var resolution: Vector2i = DisplayServer.screen_get_size()
		var fullscrn_index = Util.get_resolution_index(resolution)
		if fullscrn_index != -1:
			Util.settings.fullscreen_resolution_index = fullscrn_index
			print("Set Fullscreen Index to: ", fullscrn_index)
		else:
			push_error("Fullsreen Index lookup returned -1")
		var vec3res = Util.RESOLUTIONS.get(Util.RESOLUTIONS_INDEX[fullscrn_index])
		_set_font_size(vec3res)
		DisplayServer.window_set_size(resolution)
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
		resolution_dropdown.selected = Util.settings.fullscreen_resolution_index
		resolution_dropdown.disabled = true
		Util.settings.fullscreen = true
	else:
		var wndw_res_idx = Util.settings.windowed_resolution_index
		var res: Vector3i = Util.RESOLUTIONS.get(Util.RESOLUTIONS_INDEX[wndw_res_idx])
		print("Window Resolution Index: ", wndw_res_idx)
		print("Window Resolution: ", res)
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(res.x, res.y))
		_set_font_size(res)
		resolution_dropdown.selected = Util.settings.windowed_resolution_index
		resolution_dropdown.disabled = false
		Util.settings.fullscreen = false
	Util.save_settings()

func _on_master_vol_slider_value_changed(value: float) -> void:
	_update_volume_value(VOLUME_SLIDER_BUS.MASTER, value)
	_update_volume_label(VOLUME_SLIDER_BUS.MASTER, value)
	Util.settings.master_vol = value
	Util.save_settings()

func _on_music_vol_slider_value_changed(value: float) -> void:
	_update_volume_value(VOLUME_SLIDER_BUS.MUSIC, value)
	_update_volume_label(VOLUME_SLIDER_BUS.MUSIC, value)
	Util.settings.music_vol = value
	Util.save_settings()

func _on_game_vol_slider_value_changed(value: float) -> void:
	_update_volume_value(VOLUME_SLIDER_BUS.GAME, value)
	_update_volume_label(VOLUME_SLIDER_BUS.GAME, value)
	Util.settings.game_vol = value
	Util.save_settings()

func _update_volume_value(bus_index: int, value: float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

func _update_volume_label(bus_index: int, value: float) -> void:
	match bus_index:
		0:
			master_vol_label.text = "Main Volume: " + str(int(value * 100)) + "%"
		1:
			music_vol_label.text = "Music Volume: " + str(int(value * 100)) + "%"
		2:
			game_vol_label.text = "Game Volume: " + str(int(value * 100)) + "%"
		_:
			push_warning("Invalid Bus Index passed to _update_volume_label: ",
			bus_index)

func _on_mute_toggled(toggled_on: bool) -> void:
		AudioServer.set_bus_mute(VOLUME_SLIDER_BUS.MASTER, toggled_on)
		Util.settings.mute = toggled_on
		Util.save_settings()

func _on_d_font_toggled(toggled_on: bool) -> void:
	var res_idx = Util.get_resolution_index(DisplayServer.window_get_size())
	var res = Util.RESOLUTIONS.get(Util.RESOLUTIONS_INDEX[res_idx])
	if toggled_on:
		Util.project_theme.default_font = Util.dys_font
		Util.settings.dyslexic_font = true
		_set_font_size(res)
	else:
		Util.project_theme.default_font = Util.def_font
		Util.settings.dyslexic_font = false
		_set_font_size(res)
	Util.save_settings()

func _set_font_size(res: Vector3i) -> void:
	if Util.settings.dyslexic_font:
		Util.project_theme.default_font_size = res.z + 2
	else:
		Util.project_theme.default_font_size = res.z
