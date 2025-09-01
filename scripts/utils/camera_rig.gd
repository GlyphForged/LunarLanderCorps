extends Node3D

class_name CameraRig

@export var lander: RigidBody3D

# === Camera Properties ===
@export var mouse_sens := 0.1
@export var joy_sens := 0.015
@export var cam_fov_min: float = 45.0
@export var cam_fov_max: float = 115.0
@export var cam_zoom_step: float = 5.0
@export var cam_zoom_smooth: float = 10.0
@export var camera_mode: Util.CAMERA_MODE = Util.CAMERA_MODE.FREE
const CAM_STICK_SENS: float = 10.0

@onready var h_pivot: Node3D = %HPivot
@onready var v_pivot: Node3D = %VPivot
@onready var cam: Camera3D = %VPivot/Camera3D

var _target_fov: float = 75.0
var look_input := Vector2.ZERO
var deadzone: float = 0.1

func _ready() -> void:
	_target_fov = clamp(cam.fov, cam_fov_min, cam_fov_max)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Signals.mouse_sens_changed.connect(update_mouse_sens)
	Signals.joy_sens_changed.connect(update_joy_sens)

func _process(delta: float) -> void:
	# Camera follows the lander's position
	if is_instance_valid(lander):
		self.global_position = lander.position
	_update_fov(delta)
	_process_joystick(delta)

func _process_joystick(delta: float) -> void:
	var joy = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	)
	if absf(joy.x) < deadzone: joy.x = 0.0
	if absf(joy.y) < deadzone: joy.y = 0.0
	joy.x = clamp(joy.x * joy_sens, -1.0, 1.0)
	joy.y = clamp(-joy.y * joy_sens, -1.0, 1.0)

	h_pivot.rotate_y(-joy.x)
	v_pivot.rotate_x(-joy.y)
	v_pivot.rotation_degrees = clamp(
		v_pivot.rotation_degrees, Vector3(-60, 0, 0), Vector3(60, 0, 0)
	)
	#print(joy.x, ",", joy.y)

func _input(e: InputEvent) -> void:
	if e is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		h_pivot.rotate_y(deg_to_rad(-e.relative.x) * mouse_sens)
		if camera_mode == Util.CAMERA_MODE.HORIZON_LOCK:
			v_pivot.rotation_degrees = clamp(
				v_pivot.rotation_degrees,
				Vector3(0, 0, 0),
				Vector3(0, 0, 0)
			)
		elif camera_mode == Util.CAMERA_MODE.FREE:
			v_pivot.rotate_x(deg_to_rad(e.relative.y) * mouse_sens)
			v_pivot.rotation_degrees = clamp(
				v_pivot.rotation_degrees,
				Vector3(-60, 0, 0),
				Vector3(60, 0, 0)
			)

	if e is InputEventMouseButton and e.pressed:
		match e.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				_apply_zoom(+1.0)
			MOUSE_BUTTON_WHEEL_DOWN:
				_apply_zoom(-1.0)

func set_lander(new_lander: RigidBody3D) -> void:
	lander = new_lander

func handle_camera_input():
	if Input.is_action_just_pressed("camera-mode"):
		camera_mode = (camera_mode + 1) % 2 as Util.CAMERA_MODE

	look_input.x = Input.get_action_strength("look-right") * CAM_STICK_SENS - Input.get_action_strength("look-left") * CAM_STICK_SENS
	look_input.y = Input.get_action_strength("look-up") * CAM_STICK_SENS - Input.get_action_strength("look-down") * CAM_STICK_SENS

	if Input.is_action_just_pressed("zoom-in"):
		_apply_zoom(+1.0)
	if Input.is_action_just_pressed("zoom-out"):
		_apply_zoom(-1.0)

func _apply_zoom(delta_sign: float):
	if cam == null:
		return
	_target_fov = clamp(_target_fov - delta_sign * cam_zoom_step, cam_fov_min, cam_fov_max)

func _update_fov(dt: float):
	if cam == null:
		return
	if cam_zoom_smooth <= 0.0:
		cam.fov = _target_fov
	else:
		cam.fov = lerp(cam.fov, _target_fov, clamp(dt * cam_zoom_smooth, 0.0, 1.0))

func on_save_game(cam_data: SaveData) -> void:
	cam_data.position = self.global_position
	cam_data.scene_path = scene_file_path

func on_load_game(cam_data: SaveData) -> void:
	self.global_position = cam_data.position

func update_joy_sens(value: float) -> void:
	self.joy_sens = value

func update_mouse_sens(value: float) -> void:
	self.mouse_sens = value
