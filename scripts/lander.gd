extends RigidBody3D

const CAM_STICK_SENS: float = 10.0

@onready var h_cam_pivot: Node3D = $"../h-cam-pivot"
@onready var v_cam_pivot: Node3D = $"../h-cam-pivot/v-cam-pivot"

# === Movement ===
@export var thrust_str := 10
@export var control_thrust_str := 0.5
@export var control_thrust_offset := 1.5

# === Camera Properties ===
@export var h_cam_sens = 0.1
@export var v_cam_sens = 0.1

# === Internal Variables ===
var is_thrusting := false
var rotation_input := Vector2.ZERO
var look_input := Vector2.ZERO
var roll_input := 0.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(e):
	if e is InputEventMouseMotion:
		h_cam_pivot.rotate_y(deg_to_rad(-e.relative.x) * h_cam_sens)
		v_cam_pivot.rotate_x(deg_to_rad(-e.relative.y) * v_cam_sens)

func _physics_process(_delta: float):
	handle_input()

	if is_thrusting:
		var thrust_direction = self.global_transform.basis.y.normalized()
		var thrust_force = thrust_direction * thrust_str
		self.apply_central_force(thrust_force)
		if DebugDraw3D:
			DebugDraw3D.draw_line(
				self.global_position,
				self.global_position - thrust_force * 0.1,
				Color.RED, 0)

	var lander_up = self.global_transform.basis.y
	var lander_right = self.global_transform.basis.x
	var lander_forward = self.global_transform.basis.z
	var control_offset = lander_up * control_thrust_offset

	# Pitch up/down (W/S)
	if rotation_input.y != 0:
		var pitch_force = lander_forward * control_thrust_str * rotation_input.y
		self.apply_force(pitch_force, control_offset)
		if DebugDraw3D:
			DebugDraw3D.draw_line(\
				self.global_position + control_offset,
				self.global_position + control_offset - pitch_force * 5,
				Color.BLUE,
				0.
			)

	# Yaw left/right (A/D)
	if rotation_input.x != 0:
		var yaw_force = lander_right * control_thrust_str * -rotation_input.x
		self.apply_force(yaw_force, control_offset)
		if DebugDraw3D:
			DebugDraw3D.draw_line(
				self.global_position + control_offset,
				self.global_position + control_offset - yaw_force * 5,
				Color.GREEN,
				0.0
			)

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

	h_cam_pivot.rotate_y(deg_to_rad(-look_input.x) * h_cam_sens * _delta * 100.0)
	v_cam_pivot.rotate_x(deg_to_rad(-look_input.y) * v_cam_sens * _delta * 100.0)

	# Camera follows lander
	h_cam_pivot.global_position = self.global_position

func handle_input():
	# Reset every frame
	is_thrusting = false
	rotation_input = Vector2.ZERO
	look_input = Vector2.ZERO
	roll_input = 0.0

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

	if Input.is_action_just_pressed("mouse-mode-toggle"):
		match Input.mouse_mode:
			Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			_: print(Input.mouse_mode)

	look_input.x = Input.get_action_strength("look-right") * CAM_STICK_SENS - Input.get_action_strength("look-left") * CAM_STICK_SENS
	look_input.y = Input.get_action_strength("look-up") * CAM_STICK_SENS - Input.get_action_strength("look-down") * CAM_STICK_SENS
