extends Node

# === GLOBAL VARS ===
var settings: UserSettings = load_settings()
var project_theme: Theme = load(Util.THEME_ID)
var def_font: FontFile = load(Util.DEF_FONT_ID)
var dys_font: FontFile = load(Util.DYS_FONT_ID)
var mouse_mode_cache: Input.MouseMode

# === CONSTS ===
# UIDs
const GAME_ID: String = "uid://da6rrxer76heh"
const MENU_ID: String = "uid://brrmfqhktxady"
const PAUSE_ID: String = "uid://cuo3ndngmt4yq"
const THEME_ID: String = "uid://b0f1g2k7xxm12"
const DEF_FONT_ID: String = "uid://sx2fcvd377a2"
const DYS_FONT_ID: String = "uid://ga80iuf7p686"
const LANDER_ID: String = "uid://woljfvnriix0"
const CAM_RIG_ID: String = "uid://c050hpkcnfdea"
const INF_TERRAIN_ID: String = "uid://crn5r6ro7r2ka"
const PAD_SPAWNER_ID: String = "uid://bu7u4cigsr257"
const MISSION_CONTROLLER_ID: String = "res://scenes/utils/mission_controller.tscn"
const SAVER_LOADER_ID: String = "uid://cgpj7l1s3jgsj"
const CHUNK_ID: String = "uid://cmy0pvr4ggnac"
const TARGET_VECTOR_ID: String = "res://scenes/ui/target_vector.tscn"
const UPGRADE_POPUP_ID: String = "res://scenes/ui/upgrade_popup.tscn"
const LANDING_PAD_SMALL_ID: String = "uid://c1xambinq3m62"
const LANDING_PAD_MEDIUM_ID: String = "uid://dbm8c61dgc3tx"
const LANDING_PAD_LARGE_ID: String = "uid://b66ymy13i5weg"
const JUKEBOX_ID: String = "uid://bn4uiacj1xjrm"
const CRT_ID: String = "uid://iva6stjv07ds"
const DEATH_ID: String = "uid://dqtv00goxlx8h"
const TUTORIAL_ID: String = "uid://djir0u5rulmf5"

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

# === ENUMS ===
enum GAME_SCENES {GAME, MENU}
enum CAMERA_MODE {HORIZON_LOCK, FREE}
enum PAD_DIFFICULTY {EASY, NORMAL, HARD}

# === UTIL FUNCTIONS ===
func _ready() -> void:
	var fs: DisplayServer.WindowMode
	var res: Vector3i = Util.RESOLUTIONS.get(
		Util.RESOLUTIONS_INDEX[Util.settings.windowed_resolution_index]
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

func refresh_settings() -> void:
	settings = ResourceLoader.load("user://user_settings.tres")

func get_resolution_index(res: Vector2i) -> int:
	var res_string = str(res.x) + " x " + str(res.y)
	var res_index = Util.RESOLUTIONS_INDEX.find_key(res_string)
	if res_index != null:
		return res_index
	else:
		push_warning("Res Index did not return a valid value: ", res_index, res_string)
		return 3 # Default so we don't crash
