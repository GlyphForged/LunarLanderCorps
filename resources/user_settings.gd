class_name UserSettings
extends Resource

@export var dyslexic_font: bool
@export var font_size: int
@export var fullscreen: bool
@export var windowed_resolution_index: int
@export var fullscreen_resolution_index: int
@export var mute: bool
@export var master_vol: float
@export var music_vol: float
@export var game_vol: float
@export var tutorial_seen: bool

func _init(
	i_dyslexic_font = false,
	i_font_size = 20,
	i_fullscreen = false,
	i_resolution_index = 11,
	i_fullscreen_resolution_index = 11,
	i_mute = false,
	i_master_vol = 1,
	i_music_vol = 1,
	i_game_vol = 1,
	i_tutorial_seen = false
):
	dyslexic_font = i_dyslexic_font
	font_size = i_font_size
	fullscreen = i_fullscreen
	windowed_resolution_index = i_resolution_index
	fullscreen_resolution_index = i_fullscreen_resolution_index
	mute = i_mute
	master_vol = i_master_vol
	music_vol = i_music_vol
	game_vol = i_game_vol
	tutorial_seen = i_tutorial_seen
