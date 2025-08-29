extends Node
class_name MissionController

@onready var pads = get_tree().get_nodes_in_group("landing_pads")
@export var current_target_index: int
@export var mission_reward: int
var prior_pad_index: int
var rng = RandomNumberGenerator.new()
var mission_timer = Time.get_ticks_msec()

func _ready() -> void:
	Signals.landed_safely.connect(_check_landing_pad)

func _check_landing_pad(index: int) -> void:
	if index == self.current_target_index:
		Signals.landed_on_target_pad.emit()
		_get_new_mission(index)

func _select_mission_target(current_pad:int) -> int:
	var curr_pad_index = pads.find(pads[current_pad])
	var target_pad = -1
	while target_pad == -1:
		var rand_index = rng.randi_range(0, pads.size() - 1)
		if rand_index != curr_pad_index:
			target_pad = rand_index
	return target_pad

func _calculate_mission_reward(
	curr_pad: int,
	target_pad: int
) -> int:
	# for now the distance / 10 (always rounded up) is the score, may fuck with this later
	var curr_pad_pos = _get_target_pos(curr_pad)
	var target_pad_pos = _get_target_pos(target_pad)
	return ceil(curr_pad_pos.distance_to(target_pad_pos) / 10)

func _award_mission_points() -> void:
	print("Awarded ", self.mission_reward, " pts.")
	Signals.points_awarded.emit(self.mission_reward)
	self.mission_reward = 0

func _get_new_mission(signal_data: int) -> void:
	pads = get_tree().get_nodes_in_group("landing_pads")
	if Time.get_ticks_msec() - mission_timer > 5000 \
	and signal_data == self.current_target_index:
		self.current_target_index = _select_mission_target(signal_data)
		var target_pos = _get_target_pos(self.current_target_index)
		print("New Mission Target: Landing Pad ", self.current_target_index)
		print("Target coordinates: ", target_pos)
		Signals.target_assigned.emit(target_pos)
		_award_mission_points()
		self.mission_reward = _calculate_mission_reward(
			signal_data,
			self.current_target_index )

func _get_target_pos(target_index: int) -> Vector3:
	return pads[target_index].global_position

#########################################
#				SAVE/LOAD				#
#########################################

func on_save_game(mission_data: MissionData) -> void:
	mission_data.position = Vector3.ZERO # No need for this data
	mission_data.scene_path = scene_file_path # Technically no need for this
	mission_data.mission_reward = self.mission_reward
	mission_data.target_index = self.current_target_index

func on_load_game(mission_data: MissionData) -> void:
	# So, because we free the pads, trying to just pick the same pad
	# throws an error. Instead, generate a new pad. This seems to be
	# deterministic, and will seemingly select the same pad we chose
	# before save, so there's that.
	self.current_target_index = mission_data.target_index
	self.mission_reward = mission_reward
