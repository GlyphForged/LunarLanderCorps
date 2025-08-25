class_name LanderResource
extends Resource

@export var current_damage: float
@export var current_fuel: float
@export var max_fuel: float
@export var location: Vector3
@export var camera_mode: Util.CAMERA_MODE
@export var thrust_mult: float
@export var control_mult: float
@export var cam_fov: float
@export var has_sas: bool

func _init(
	i_current_damage = 0.,
	i_current_fuel = 100.,
	i_max_fuel = 100.,
	i_location = Vector3(0., 40., 0.),
	i_camera_mode = Util.CAMERA_MODE.FREE,
	i_thrust_mult = 1.0,
	i_control_mult = 1.0,
	i_cam_fov = 75.0,
	i_has_sas = false,
):
	current_damage = i_current_damage
	current_fuel   = i_current_fuel
	max_fuel       = i_max_fuel
	location       = i_location
	camera_mode    = i_camera_mode
	thrust_mult    = i_thrust_mult
	control_mult   = i_control_mult
	cam_fov        = i_cam_fov
	has_sas        = i_has_sas
