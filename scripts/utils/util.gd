extends Node

# === CONSTS ===
const GAME_PATH: String = "res://scenes/game.tscn"
const MENU_PATH: String = "res://scenes/ui/main_menu.tscn"

# === ENUMS ===
enum GAME_SCENES {GAME, MENU}
enum CAMERA_MODE {HORIZON_LOCK, FREE}

# === UTIL FUNCTIONS ===
func set_margins(node: MarginContainer, hPerc: float, vPerc: float) -> void:
	var margin_container: MarginContainer = node
	var hmargin: int = floor(hPerc * get_window().get_visible_rect().size.x)
	var vmargin: int = floor(vPerc * get_window().get_visible_rect().size.y)
	margin_container.add_theme_constant_override("margin_left", hmargin)
	margin_container.add_theme_constant_override("margin_right", hmargin)
	margin_container.add_theme_constant_override("margin_top", vmargin)
	margin_container.add_theme_constant_override("margin_bottom", vmargin)
