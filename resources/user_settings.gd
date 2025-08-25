class_name UserSettings
extends Resource

@export var dyslexic_font: bool
@export var font_size: int
@export var fullscreen: bool
@export var resolution_index: int
@export var mute: bool
@export var vol: float

func _init(
	i_dyslexic_font = false,
	i_font_size = 20,
	i_fullscreen = false,
	i_resolution_index = 11,
	i_mute = false,
	i_vol = 1
):
	dyslexic_font = i_dyslexic_font
	font_size = i_font_size
	fullscreen = i_fullscreen
	resolution_index = i_resolution_index
	mute = i_mute
	vol = i_vol
