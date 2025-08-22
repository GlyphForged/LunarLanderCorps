extends Control

const WINDOW_RESOLUTION_OPTIONS: Array[String] = [
	"2560 x 1440",
	"1920 x 1080",
	"1600 x 900",
	"1280 x 720",
]

@onready var actions := InputMap.get_actions()

#func _ready() -> void:
#var input_key: InputEventKey
#var input_action: InputEventAction
	#for action in actions:
		#if !action.begins_with("ui_"):
			#var action_button = InputMap.action_get_events(action)
			#for bttn in action_button:
				#if bttn.get_class() = InputEventKey:
					#input_key = bttn
				#elif bttn.get_class() = InputEventAction:
					#input_action = bttn

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if is_visible():
			%BackBtn.grab_focus()

func _on_back_btn_pressed() -> void:
	var main_menu = get_tree().get_node("MainMenu")
	main_menu.show()
	# TODO: Show the rest

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
	print(str(AudioServer.get_bus_volume_db(0)))

func _on_mute_toggled(toggled_on: bool) -> void:
		AudioServer.set_bus_mute(0, toggled_on)
