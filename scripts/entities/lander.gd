extends RigidBody3D

const CAM_STICK_SENS: float = 10.0

# === Movement ===
@export var thrust_str := 2.5
@export var control_thrust_str := 0.3
@export var control_thrust_offset := 0.8

# === Damage ===
@export var damage_offset := 0.4
@export var current_damage := 0.0
@export var leg_strength := 0.5
var safe_collider_count := 4

# === Internal Variables ===
var is_thrusting := false
var rotation_input := Vector2.ZERO
var look_input := Vector2.ZERO
var roll_input := 0.0

# === Camera Config ===
# Camera Properties
@onready var lander: RigidBody3D = %Lander
@export var camera_path: NodePath
@onready var h_pivot: Node3D = %CameraRig/%HPivot
@onready var v_pivot: Node3D = %CameraRig/%VPivot
@export var h_cam_sens := 0.1
@export var v_cam_sens := 0.1
@export var cam_fov_min: float = 45.0
@export var cam_fov_max: float = 115.0
@export var cam_zoom_step: float = 5.0
@export var cam_zoom_smooth: float = 10.0
@export var camera_mode := Util.CAMERA_MODE.FREE
@export var control_mode := handle_input

@onready var cam: Camera3D = (
	get_node_or_null(camera_path) as Camera3D
	if camera_path != NodePath("")
	else (v_pivot.get_child(0) as Camera3D if v_pivot.get_child_count() > 0 and v_pivot.get_child(0) is Camera3D else null)
)

var _target_fov: float = 75.0

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

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if cam:
		_target_fov = clamp(cam.fov, cam_fov_min, cam_fov_max)

func _input(e):
	if e is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		h_pivot.rotate_y(deg_to_rad(-e.relative.x) * h_cam_sens)
		if camera_mode == Util.CAMERA_MODE.HORIZON_LOCK:
			v_pivot.rotation_degrees = clamp(
				v_pivot.rotation_degrees,
				Vector3(0, 0, 0),
				Vector3(0, 0, 0)
			)
		elif camera_mode == Util.CAMERA_MODE.FREE:
			v_pivot.rotate_x(deg_to_rad(e.relative.y) * v_cam_sens)
			v_pivot.rotation_degrees = clamp(
				v_pivot.rotation_degrees,
				Vector3(-60, 0, 0),
				Vector3(35, 0, 0)
			)

	if e is InputEventMouseButton and e.pressed:
		match e.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				_apply_zoom(+1.0)
			MOUSE_BUTTON_WHEEL_DOWN:
				_apply_zoom(-1.0)

func apply_tilt(input, reference_direction, offset, color):
	if input != 0:
		var pitch_force = reference_direction * control_thrust_str * input
		self.apply_force(pitch_force, offset)
		if DebugDraw3D:
			DebugDraw3D.draw_line(\
				self.global_position + offset,
				self.global_position + offset - pitch_force * 5,
				color,
				0.
			)
func _process(_delta: float):
	self.control_mode.call()

	# Camera follows lander
	%CameraRig.position = lander.position
	_update_fov(_delta)

func _physics_process(_delta: float):

	if is_thrusting:
		var thrust_direction = self.global_transform.basis.y.normalized()
		var thrust_force = thrust_direction * thrust_str
		self.apply_central_force(thrust_force)
		if DebugDraw3D:
			DebugDraw3D.draw_line(
				self.global_position,
				self.global_position - thrust_force,
				Color.RED, 0)

	var lander_up = self.global_transform.basis.y
	var lander_right = self.global_transform.basis.x
	var lander_forward = self.global_transform.basis.z
	var control_offset = lander_up * control_thrust_offset

	# Pitch up/down (W/S)
	apply_tilt(rotation_input.y, lander_forward, control_offset, Color.BLUE)
	apply_tilt(-rotation_input.y, lander_forward, -control_offset, Color.DARK_BLUE)

	# Yaw left/right (A/D)
	apply_tilt(-rotation_input.x,lander_right,control_offset, Color.GREEN)
	apply_tilt(rotation_input.x,lander_right,-control_offset, Color.DARK_GREEN)

	# Roll (Q/E)
	if roll_input != 0:
		var roll_torque = -lander_up * control_thrust_str * roll_input
		self.apply_torque(roll_torque)
		if DebugDraw3D:
			DebugDraw3D.draw_line(
				self.global_position,
				self.global_position + roll_torque * 0.5,
				Color.ORANGE,
				0.0
			)

func handle_mouse_mode_input():
	if Input.is_action_just_pressed("mouse-mode-toggle"):
		match Input.mouse_mode:
			Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			_: print(Input.mouse_mode)

func handle_camera_input():
	if Input.is_action_just_pressed("camera-mode"):
		camera_mode = (camera_mode + 1) % 2 as Util.CAMERA_MODE

	look_input.x = Input.get_action_strength("look-right") * CAM_STICK_SENS - Input.get_action_strength("look-left") * CAM_STICK_SENS
	look_input.y = Input.get_action_strength("look-up") * CAM_STICK_SENS - Input.get_action_strength("look-down") * CAM_STICK_SENS

	if Input.is_action_just_pressed("zoom-in"):
		_apply_zoom(+1.0)
	if Input.is_action_just_pressed("zoom-out"):
		_apply_zoom(-1.0)

func reset_input():
	is_thrusting = false
	rotation_input = Vector2.ZERO
	look_input = Vector2.ZERO
	roll_input = 0.0

func handle_input():
	# Reset every frame
	reset_input()

	handle_mouse_mode_input()
	handle_camera_input()

	if Input.is_action_pressed("thrust"):
		is_thrusting = true

	if Input.is_action_pressed("yaw-l"):
		rotation_input.x += 1
	if Input.is_action_pressed("yaw-r"):
		rotation_input.x -= 1
	if Input.is_action_pressed("pitch-up"):
		rotation_input.y += 1
	if Input.is_action_pressed("pitch-down"):
		rotation_input.y -= 1
	if Input.is_action_pressed("roll-l"):
		roll_input += 1
	if Input.is_action_pressed("roll-r"):
		roll_input -= 1

	if Input.is_action_just_pressed('input-mode-toggle'):
		self.control_mode = handle_debug_input
		self.gravity_scale = 0

func handle_debug_input():
	reset_input()
	handle_mouse_mode_input()
	handle_camera_input()

	if Input.is_action_just_pressed('input-mode-toggle'):
		self.control_mode = handle_input
		self.gravity_scale = 1

	# rather than generate yet another inputmap for a non-user-facing feature
	# we just cheat and repurpose

	# yaw is lateral strafe
	if Input.is_action_pressed("yaw-l"):
		position.x += 1
	if Input.is_action_pressed("yaw-r"):
		position.x -= 1

	# pitch is forward/backwards
	if Input.is_action_pressed("pitch-up"):
		position.z += 1
	if Input.is_action_pressed("pitch-down"):
		position.z -= 1

	# roll, very counterintuitively, is up down. rightward is up
	if Input.is_action_pressed("roll-l"):
		position.y += 1
	if Input.is_action_pressed("roll-r"):
		position.y -= 1


func _on_body_shape_entered(_body_rid: RID, _body: Node, _body_shape_index: int, local_shape_index: int) -> void:
	# slightly unreasonable approach; we have placed all the safe colliders in
	# the top 4 positions in the collider list.
	# currently, we do not need to care what we hit for this to count.
	if local_shape_index < safe_collider_count:
		if self.linear_velocity.y > leg_strength:
			apply_damage(self.linear_velocity, self.rotation)
		else:
			return
	apply_damage(self.linear_velocity, self.rotation)

func apply_damage(velocity: Vector3, _angle: Vector3):
	var lateral_damage: float = max(abs(velocity.z), abs(velocity.x)) - damage_offset
	if lateral_damage < 0:
		lateral_damage = 0
	var vertical_damage: float
	if ((velocity.y > 0) and (velocity.y - damage_offset > 0)):
		vertical_damage = velocity.y - damage_offset
	var damage = vertical_damage + lateral_damage
	self.current_damage += damage
