extends Control

const WINDOW_RESOLUTION_OPTIONS: Array[String] = [
	"2560 x 1440",
	"1920 x 1080",
	"1600 x 900",
	"1280 x 720",
]

func _ready() -> void:
	%BackBtn.call_deferred("grab_focus")

	var margin_container: MarginContainer = self.get_node("MarginContainer")
	Util.set_margins(margin_container, 0.2, 0.15)

func _on_back_btn_pressed() -> void:
	Signals.settings_closed.emit()
	self.queue_free()

func _on_resolution_selected(index: int) -> void:
	match index:
		0: # 2560 x 1440
			DisplayServer.window_set_size(Vector2i(2560, 1440))
		1: # 1920 x 1080
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		2: # 1600 x 900
			DisplayServer.window_set_size(Vector2i(1600, 900))
		3: # 1280 x 720
			DisplayServer.window_set_size(Vector2i(1280, 720))

func _on_fs_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)

func _on_vol_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_mute_toggled(toggled_on: bool) -> void:
		AudioServer.set_bus_mute(0, toggled_on)
