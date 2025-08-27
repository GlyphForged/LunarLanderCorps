extends RigidBody3D

class_name Lander

# === Movement ===
var control_mode := handle_input
var thrust_str := 2.5
var control_thrust_str := 0.3
var control_thrust_offset := 0.8

# === Damage ===
@export var damage_offset := 0.5
@export var current_damage := 0.0
@export var leg_strength := 2.0
var next_damage := 0.0
var safe_collider_count := 4
var velocity_cache := Vector3.ZERO
var damage_calculated_this_frame := false
var damage_points_of_contact := 0.0

# === Internal Variables ===
@export var max_fuel := 100.0
@export var control_mult := 1.0
@export var thrust_mult := 1.0
var current_fuel := 100.0
var is_thrusting := false
var rotation_input := Vector2.ZERO
var roll_input := 0.0

var thruster_firing:= false
var initial_position := Vector3(0., 40., 0.)

func _ready():
	set_deferred("global_position", initial_position)
	self.control_mode = handle_input

func apply_tilt(input, reference_direction, offset, color):
	if input != 0:
		var pitch_force = reference_direction * \
		(control_thrust_str * control_mult) * input
		self.apply_force(pitch_force, offset)
		if DebugDraw3D:
			DebugDraw3D.draw_line(
				self.global_position + offset,
				self.global_position + offset - pitch_force * 5,
				color,
				0.
			)

func thruster_sound(on: bool):
	if on:
		#$AudioStreamPlayer3D.stream
		if not $AudioStreamPlayer3D.playing:
			$AudioStreamPlayer3D.play()
		else:
			pass
	else:
		$AudioStreamPlayer3D.stop()


func _process(_delta: float):
	self.control_mode.call()

	velocity_cache = linear_velocity
	apply_damage()

func _physics_process(_delta: float):

	if is_thrusting:
		var thrust_direction = self.global_transform.basis.y.normalized()
		var thrust_force = thrust_direction * (thrust_str * thrust_mult)
		self.apply_central_force(thrust_force)
		if DebugDraw3D:
			DebugDraw3D.draw_line(
				self.global_position,
				self.global_position - thrust_force,
				Color.RED, 0)
		thruster_sound(true)
	if not is_thrusting:
		thruster_sound(false)

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

func reset_input():
	is_thrusting = false
	rotation_input = Vector2.ZERO
	roll_input = 0.0

func handle_input():
	# Reset every frame
	reset_input()

	handle_mouse_mode_input()

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
		var vertical_speed = abs(velocity_cache.y)
		if vertical_speed > leg_strength:
			calculate_damage(self.velocity_cache, self.rotation)
		else:
			return
	calculate_damage(self.velocity_cache, self.rotation)

func calculate_damage(velocity: Vector3, _angle: Vector3):
	if damage_calculated_this_frame:
		damage_points_of_contact += 1
		return
	var lateral_damage: float = max(abs(velocity.z), abs(velocity.x)) - damage_offset
	if lateral_damage < 0:
		lateral_damage = 0
	var vertical_damage: float
	var vertical_speed = abs(velocity.y)
	if ((vertical_speed > 0) and (vertical_speed - damage_offset > 0)):
		vertical_damage = vertical_speed - damage_offset
	var damage = vertical_damage + lateral_damage
	self.next_damage += damage
	damage_calculated_this_frame = true
	damage_points_of_contact = 1

func apply_damage():
	if damage_calculated_this_frame:
		damage_calculated_this_frame = false
		current_damage += (next_damage / damage_points_of_contact)
		damage_points_of_contact = 0.0
		next_damage = 0.0
