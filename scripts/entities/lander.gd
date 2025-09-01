class_name Lander
extends RigidBody3D

# CONSTANTS #
const FUEL_RATE: float = 0.01
const THRUST_STR: float = 2.5
const CONTROL_THRUST_STR: float = 0.3
const CONTROL_THRUST_OFFSET := 0.8
const POINTER_SCENE: PackedScene = preload(Util.TARGET_VECTOR_ID)
const DEATH_SCREEN: PackedScene = preload(Util.DEATH_ID)
const TUTORIAL_SCREEN: PackedScene = preload(Util.TUTORIAL_ID)

# MOVEMENT #
var control_mode := handle_input
var is_thrusting := false
var rotation_input := Vector2.ZERO
var roll_input := 0.0
var thruster_firing:= false
var initial_position := Vector3.ZERO

# GAMEPLAY #
@onready var mission_controller: MissionController = get_node("../MissionController")
@onready var main_thruster_particles: GPUParticles3D = %MainThrusterParticles
@onready var main_thruster_light: OmniLight3D = %MainThrusterLight
@onready var front_control_particles: GPUParticles3D = %FrontControlParticles
@onready var rear_control_particles: GPUParticles3D = %RearControlParticles
@onready var left_control_particles: GPUParticles3D = %LeftControlParticles
@onready var right_control_particles: GPUParticles3D = %RightControlParticles
@export_group("Gameplay Variables")
@export var paused := false
@export_subgroup("Score")
@export var total_score := 0
@export var current_pts := 0
@export_subgroup("Damage")
@export var damage_threshold := 10.0
@export var damage_offset := 0.5
@export var current_damage := 0.0
@export var leg_strength := 2.0
@export_subgroup("Fuel")
@export var max_fuel := 100.0
@export var current_fuel := 100.0
@export var fuel_efficiency := 1.00
@export_subgroup("Thrusters")
@export var control_mult := 1.0
@export var thrust_mult := 1.0
var next_damage := 0.0
var safe_collider_count := 4
var velocity_cache := Vector3.ZERO
var damage_calculated_this_frame := false
var damage_points_of_contact := 0.0
var last_pad := 0
var next_target := Node

var upgrades: Dictionary = {
	"MaxFuelUpgrade": self.max_fuel,
	"FuelEfficiencyUpgrade": self.fuel_efficiency,
	"MainThrustUpgrade": self.thrust_mult,
	"ControlThrustUpgrade": self.control_mult,
	"Repair": self.current_damage,
}

#########################################
#			NATIVE FUNCTIONS			#
#########################################
func _ready():
	self.initial_position = _get_initial_pos()
	set_deferred("global_position", initial_position)
	self.control_mode = handle_input
	Signals.points_awarded.connect(_update_score)
	Signals.landed_safely.connect(_refuel)
	Signals.landed_safely.connect(_autosave)
	Signals.landed_safely.connect(_spawn_tutorial_window)
	#_spawn_target_vector()

func _process(_delta: float):
	if self.paused:
		return
	velocity_cache = linear_velocity
	self.control_mode.call()
	_apply_damage()
	_handle_death()
	_handle_out_of_fuel()

func _physics_process(delta: float):
	if self.paused:
		return
	_update_main_light(delta)
	_main_thrust()
	_pitch_yaw_roll()

#########################################
#				MOVEMENT				#
#########################################
func _get_initial_pos() -> Vector3:
	var initial_pad = get_tree().get_nodes_in_group("landing_pads")[0]
	return initial_pad.global_position + Vector3(0., 4., 0.)

func _main_thrust() -> void:
	if self.is_thrusting and self.current_fuel > 0.0:
		var thrust_direction = self.global_transform.basis.y.normalized()
		var thrust_force = thrust_direction * (THRUST_STR * thrust_mult)
		self.apply_central_force(thrust_force)
		self.current_fuel -= self.FUEL_RATE * self.fuel_efficiency
		main_thruster_particles.emitting = true
		thruster_sound(true)
	if not is_thrusting:
		main_thruster_particles.emitting = false
		thruster_sound(false)

func _pitch_yaw_roll() -> void:
	var lander_up = self.global_transform.basis.y
	var lander_right = self.global_transform.basis.x
	var lander_forward = self.global_transform.basis.z
	var control_offset = lander_up * CONTROL_THRUST_OFFSET
	# Pitch up/down (W/S)
	apply_tilt(rotation_input.y, lander_forward, control_offset)
	apply_tilt(-rotation_input.y, lander_forward, -control_offset)

	# Yaw left/right (A/D)
	apply_tilt(-rotation_input.x,lander_right,control_offset)
	apply_tilt(rotation_input.x,lander_right,-control_offset)

	# Roll (Q/E)
	if roll_input != 0:
		var roll_torque = -lander_up * CONTROL_THRUST_STR * -roll_input
		self.apply_torque(roll_torque)

func apply_tilt(input, reference_direction, offset):
	if input != 0:
		var pitch_force = reference_direction * \
		(CONTROL_THRUST_STR * control_mult) * input
		self.apply_force(pitch_force, offset)

func thruster_sound(on: bool):
	if on:
		if not $MainThrusterSound.playing:
			$MainThrusterSound.play()
		else:
			pass
	else:
		$MainThrusterSound.stop()

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
		right_control_particles.emitting = true
	else:
		right_control_particles.emitting = false
	if Input.is_action_pressed("yaw-r"):
		rotation_input.x -= 1
		left_control_particles.emitting = true
	else:
		left_control_particles.emitting = false
	if Input.is_action_pressed("pitch-up"):
		rotation_input.y += 1
		front_control_particles.emitting = true
	else:
		front_control_particles.emitting = false
	if Input.is_action_pressed("pitch-down"):
		rotation_input.y -= 1
		rear_control_particles.emitting = true
	else:
		rear_control_particles.emitting = false
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

func _handle_death():
	if self.current_damage > self.damage_threshold:
		var autosave = ResourceLoader.load("user://autosave.res") as LanderData
		if autosave == null:
			push_error("No autosave.")
			return
		on_load_game(autosave)
		Util.mouse_mode_cache = Input.mouse_mode
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true
		var ds = DEATH_SCREEN.instantiate()
		get_tree().root.add_child(ds)
		await ds.confirmed
		get_tree().paused = false
		Input.mouse_mode = Util.mouse_mode_cache

func _update_score(signal_data: int) -> void:
	self.total_score += signal_data
	self.current_pts += signal_data

func _refuel(signal_data: int) -> void:
	if signal_data != self.last_pad:
		self.current_fuel = self.max_fuel
		self.last_pad = signal_data

func get_stat(upgrade_key: String) -> String:
	var stat = self.upgrades[upgrade_key]
	return str(stat)

func apply_upgrade(upgrade_key: String, cost: int, amt: float) -> void:
	if self.current_pts < cost:
		return # TODO: Show insufficient pts popup and return
	self.current_pts -= cost
	match upgrade_key:
		"MaxFuelUpgrade":
			self.max_fuel += amt
		"FuelEfficiencyUpgrade":
			self.fuel_efficiency -= amt
		"MainThrustUpgrade":
			self.thrust_mult += amt
		"ControlThrustUpgrade":
			self.control_mult += amt
		"Repair":
			self.current_damage = 0.0

func update_upgrade_dict() -> void:
	upgrades["MaxFuelUpgrade"] = self.max_fuel
	upgrades["FuelEfficiencyUpgrade"] = self.fuel_efficiency
	upgrades["MainThrustUpgrade"] = self.thrust_mult
	upgrades["ControlThrustUpgrade"] = self.control_mult
	upgrades["Repair"] = self.current_damage

#########################################
#					HUD					#
#########################################
func _spawn_target_vector() -> void:
	var pointer = POINTER_SCENE.instantiate()
	pointer.set_mission(mission_controller)
	self.add_child(pointer)

func _spawn_tutorial_window(_x) -> void:
	if !Util.settings.tutorial_seen:
		Util.settings.tutorial_seen = true
		Util.mouse_mode_cache = Input.mouse_mode
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true
		self.add_child(TUTORIAL_SCREEN.instantiate())
		await Signals.tutorial_confirmed
		get_tree().paused = false
		Input.mouse_mode = Util.mouse_mode_cache

#########################################
#				VISUALS					#
#########################################
func _update_main_light(delta) -> void:
	if self.is_thrusting:
		main_thruster_light.light_energy = move_toward(
			main_thruster_light.light_energy,
			10.0,
			delta * 20
		)
	else:
		main_thruster_light.light_energy = move_toward(
			main_thruster_light.light_energy,
			0.0,
			delta * 15
		)

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
func _autosave(_x) -> void:
	var autosave := LanderData.new()
	self.on_save_game(autosave)
	var err = ResourceSaver.save(autosave, "user://autosave.res")
	if err != OK:
		push_error("Something went wrong: ", err)

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
	lander_data.current_pts = self.current_pts
	lander_data.total_score = self.total_score

func on_load_game(lander_data: LanderData) -> void:
	self.linear_velocity = Vector3.ZERO
	self.angular_velocity = Vector3.ZERO
	self.current_damage = lander_data.current_damage
	self.leg_strength = lander_data.leg_strength
	self.max_fuel = lander_data.max_fuel
	self.current_fuel = lander_data.current_fuel
	self.thrust_mult = lander_data.control_mult
	self.thrust_mult = lander_data.thrust_mult
	self.global_position = lander_data.position
	self.rotation = lander_data.rotation
	self.current_pts = lander_data.current_pts
	self.total_score = lander_data.total_score
	self.update_upgrade_dict()
