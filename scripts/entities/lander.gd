class_name Lander
extends RigidBody3D

# CONSTANTS #
const FUEL_RATE: float = 0.01
const THRUST_STR: float = 2.5
const CONTROL_THRUST_STR: float = 0.3
const CONTROL_THRUST_OFFSET := 0.8
const POINTER_SCENE: PackedScene = preload(Util.TARGET_VECTOR_ID)

# MOVEMENT #
var control_mode := handle_input
var is_thrusting := false
var rotation_input := Vector2.ZERO
var roll_input := 0.0
var thruster_firing:= false
var initial_position := Vector3(0., 40., 0.)

# GAMEPLAY #
@onready var mission_controller: MissionController = get_node("../MissionController")
@export var total_score := 0
@export var current_pts := 0
@export var damage_offset := 0.5
@export var current_damage := 0.0
@export var leg_strength := 2.0
@export var max_fuel := 100.0
@export var current_fuel := 100.0
@export var fuel_efficiency := 1.00
@export var control_mult := 1.0
@export var thrust_mult := 1.0
var next_damage := 0.0
var safe_collider_count := 4
var velocity_cache := Vector3.ZERO
var damage_calculated_this_frame := false
var damage_points_of_contact := 0.0
var last_pad := 0
var next_target := Node

#########################################
#			NATIVE FUNCTIONS			#
#########################################
func _ready():
	set_deferred("global_position", initial_position)
	self.control_mode = handle_input
	Signals.points_awarded.connect(_update_score)
	Signals.landed_safely.connect(_refuel)
	_spawn_target_vector()

func _process(_delta: float):
	velocity_cache = linear_velocity
	self.control_mode.call()
	_apply_damage()
	_handle_out_of_fuel()

func _physics_process(_delta: float):
	_main_thrust()
	_pitch_yaw_roll()

#########################################
#				MOVEMENT				#
#########################################
func _main_thrust() -> void:
	if self.is_thrusting and self.current_fuel > 0.0:
		var thrust_direction = self.global_transform.basis.y.normalized()
		var thrust_force = thrust_direction * (THRUST_STR * thrust_mult)
		self.apply_central_force(thrust_force)
		if DebugDraw3D:
			DebugDraw3D.draw_line(
				self.global_position,
				self.global_position - thrust_force,
				Color.RED, 0)
		self.current_fuel -= self.FUEL_RATE * self.fuel_efficiency
		thruster_sound(true)
	if not is_thrusting:
		thruster_sound(false)

func _pitch_yaw_roll() -> void:
	var lander_up = self.global_transform.basis.y
	var lander_right = self.global_transform.basis.x
	var lander_forward = self.global_transform.basis.z
	var control_offset = lander_up * CONTROL_THRUST_OFFSET
	# Pitch up/down (W/S)
	apply_tilt(rotation_input.y, lander_forward, control_offset, Color.BLUE)
	apply_tilt(-rotation_input.y, lander_forward, -control_offset, Color.DARK_BLUE)

	# Yaw left/right (A/D)
	apply_tilt(-rotation_input.x,lander_right,control_offset, Color.GREEN)
	apply_tilt(rotation_input.x,lander_right,-control_offset, Color.DARK_GREEN)

	# Roll (Q/E)
	if roll_input != 0:
		var roll_torque = -lander_up * CONTROL_THRUST_STR * roll_input
		self.apply_torque(roll_torque)
		if DebugDraw3D:
			DebugDraw3D.draw_line(
				self.global_position,
				self.global_position + roll_torque * 0.5,
				Color.ORANGE,
				0.0
			)

func apply_tilt(input, reference_direction, offset, color):
	if input != 0:
		var pitch_force = reference_direction * \
		(CONTROL_THRUST_STR * control_mult) * input
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
		if not $AudioStreamPlayer3D.playing:
			$AudioStreamPlayer3D.play()
		else:
			pass
	else:
		$AudioStreamPlayer3D.stop()
func _handle_out_of_fuel() -> void:
	if self.current_fuel < 0.0:
		self.current_fuel = 0.0
		self.is_thrusting = false
		thruster_sound(false)

#########################################
#				INPUT					#
#########################################
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
		position.z -= 1
	if Input.is_action_pressed("pitch-down"):
		position.z += 1

	# roll, very counterintuitively, is up down. rightward is up
	if Input.is_action_pressed("roll-l"):
		position.y += 1
	if Input.is_action_pressed("roll-r"):
		position.y -= 1

#########################################
#				GAMEPLAY				#
#########################################
func _calculate_damage(velocity: Vector3, _angle: Vector3):
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

func _apply_damage():
	if damage_calculated_this_frame:
		damage_calculated_this_frame = false
		current_damage += (next_damage / damage_points_of_contact)
		damage_points_of_contact = 0.0
		next_damage = 0.0

func _update_score(signal_data: int) -> void:
	self.total_score += signal_data
	self.current_pts += signal_data

func _refuel(signal_data: int) -> void:
	print("Landed on pad: ", signal_data)
	print("Last pad: ", self.last_pad)
	if signal_data != self.last_pad:
		self.current_fuel = self.max_fuel
		self.last_pad = signal_data

#########################################
#					HUD					#
#########################################
func _spawn_target_vector() -> void:
	var pointer = POINTER_SCENE.instantiate()
	pointer.set_mission(mission_controller)
	self.add_child(pointer)

#########################################
#				SIGNALS					#
#########################################
func _on_body_shape_entered(_body_rid: RID, _body: Node, _body_shape_index: int, local_shape_index: int) -> void:
	# slightly unreasonable approach; we have placed all the safe colliders in
	# the top 4 positions in the collider list.
	# currently, we do not need to care what we hit for this to count.
	if local_shape_index < safe_collider_count:
		var vertical_speed = abs(velocity_cache.y)
		if vertical_speed > leg_strength:
			_calculate_damage(self.velocity_cache, self.rotation)
		else:
			return
	_calculate_damage(self.velocity_cache, self.rotation)

#########################################
#				SAVE/LOAD				#
#########################################
func on_save_game(lander_data:LanderData) -> void:
	lander_data.position = self.global_position
	lander_data.rotation = self.rotation
	lander_data.scene_path = scene_file_path
	lander_data.current_damage = self.current_damage
	lander_data.leg_strength = self.leg_strength
	lander_data.max_fuel = self.max_fuel
	lander_data.current_fuel = self.current_fuel
	lander_data.control_mult = self.control_mult
	lander_data.thrust_mult = self.thrust_mult

func on_load_game(saved_data: SaveData) -> void:
	if saved_data is LanderData:
		var lander_data = saved_data as LanderData
		self.global_position = lander_data.position
		self.rotation = lander_data.rotation
		self.current_damage = lander_data.current_damage
		self.leg_strength = lander_data.leg_strength
		self.max_fuel = lander_data.max_fuel
		self.current_fuel = lander_data.current_fuel
		self.thrust_mult = lander_data.control_mult
		self.thrust_mult = lander_data.thrust_mult
		self.linear_velocity = Vector3.ZERO
		self.angular_velocity = Vector3.ZERO
