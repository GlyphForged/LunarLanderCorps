extends Node

# === GLOBAL VARS ===
var settings: UserSettings = load_settings()
var l_res: LanderResource = load_lander_resource()
var project_theme: Theme = load(Util.THEME_ID)
var def_font: FontFile = load(Util.DEF_FONT_ID)
var dys_font: FontFile = load(Util.DYS_FONT_ID)

# === CONSTS ===
const GAME_PATH: String = "res://scenes/game.tscn"
const MENU_PATH: String = "res://scenes/ui/main_menu.tscn"

const RESOLUTIONS: Dictionary = {
	"3840 x 2160": Vector3i(3840, 2160, 24),
	"3440 x 1440": Vector3i(3440, 1440, 24),
	"2560 x 1600": Vector3i(2560, 1600, 24),
	"2560 x 1440": Vector3i(2560, 1440, 24),
	"2560 x 1080": Vector3i(2560, 1080, 24),
	"1920 x 1080": Vector3i(1920, 1080, 20),
	"1920 x 1200": Vector3i(1920, 1200, 20),
	"1440 x 900" : Vector3i(1440, 900, 16),
	"1366 x 768" : Vector3i(1366, 768, 16),
}

const RESOLUTIONS_INDEX: Dictionary = {
	1: "3840 x 2160",
	2: "2560 x 1440",
	3: "1920 x 1080",
	4: "1366 x 768" ,
	6: "2560 x 1600",
	7: "1920 x 1200",
	8: "1440 x 900" ,
	10: "3440 x 1440",
	11: "2560 x 1080",
}

# UIDs
const THEME_ID: String = "uid://b0f1g2k7xxm12"
const DEF_FONT_ID: String = "uid://sx2fcvd377a2"
const DYS_FONT_ID: String = "uid://ga80iuf7p686"

# === ENUMS ===
enum GAME_SCENES {GAME, MENU}
enum CAMERA_MODE {HORIZON_LOCK, FREE}

# === UTIL FUNCTIONS ===
func _ready() -> void:
	var fs: DisplayServer.WindowMode
	var res: Vector3i = Util.RESOLUTIONS.get(
		Util.RESOLUTIONS_INDEX[Util.settings.resolution_index]
	)
	if Util.settings.fullscreen:
		fs = DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN
	else:
		fs = DisplayServer.WindowMode.WINDOW_MODE_WINDOWED
	if settings:
		DisplayServer.window_set_mode(fs)
	DisplayServer.window_set_size(Vector2i(res.x, res.y))
	# Font Fuckery
	if settings.dyslexic_font:
		project_theme.default_font = dys_font
		project_theme.default_font_size = res.z - 4
	else:
		project_theme.default_font = def_font
		project_theme.default_font_size = res.z
		settings.font_size = res.z


func set_margins(node: MarginContainer, hPerc: float, vPerc: float) -> void:
	var margin_container: MarginContainer = node
	var hmargin: int = floor(hPerc * get_window().get_visible_rect().size.x)
	var vmargin: int = floor(vPerc * get_window().get_visible_rect().size.y)
	margin_container.add_theme_constant_override("margin_left", hmargin)
	margin_container.add_theme_constant_override("margin_right", hmargin)
	margin_container.add_theme_constant_override("margin_top", vmargin)
	margin_container.add_theme_constant_override("margin_bottom", vmargin)

func load_settings() -> UserSettings:
	if FileAccess.file_exists("user://user_settings.tres"):
		return ResourceLoader.load("user://user_settings.tres")
	else:
		return UserSettings.new()

func  save_settings() -> void:
	var error = ResourceSaver.save(Util.settings, "user://user_settings.tres")
	if error != OK:
		push_error("Error saving settings: ", error)
	else:
		print("Settings updated successfully.")

func refresh_settings() -> void:
	settings = ResourceLoader.load("user://user_settings.tres")

func load_lander_resource() -> LanderResource:
	if FileAccess.file_exists("user://lander_res.tres"):
		return ResourceLoader.load("user://lander_res.tres")
	else :
		return LanderResource.new()

func save_lander_resource() -> void:
	var err = ResourceSaver.save(Util.l_res, "user://lander_res.tres")
	if err != OK:
		push_error("Error saving lander resource: ", err)
	else:
		print("Lander Resource saved.")
