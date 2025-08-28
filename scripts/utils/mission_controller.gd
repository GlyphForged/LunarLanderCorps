extends Node
class_name MissionController

@onready var pads = get_tree().get_nodes_in_group("landing_pads")
@export var current_target_index: int
@export var mission_reward: int
var prior_pad_index: int
var rng = RandomNumberGenerator.new()
var mission_timer = Time.get_ticks_msec()

func _ready() -> void:
	Signals.landed_safely.connect(_get_new_mission)

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
	var curr_pad_pos = pads[curr_pad].global_position
	var target_pad_pos = pads[target_pad].global_position
	return ceil(curr_pad_pos.distance_to(target_pad_pos) / 10)

func _award_mission_points() -> void:
		print("Awarded ", self.mission_reward, " pts.")
		Signals.points_awarded.emit(self.mission_reward)
		self.mission_reward = 0

func _get_new_mission(signal_data: int) -> void:
	if Time.get_ticks_msec() - mission_timer > 5000 \
	and signal_data == self.current_target_index:
		self.current_target_index = _select_mission_target(signal_data)
		var target_pos = pads[self.current_target_index].global_position
		print("New Mission Target: Landing Pad ", self.current_target_index)
		print("Target coordinates: ", target_pos)
		Signals.target_assigned.emit(target_pos)
		_award_mission_points()
		self.mission_reward = _calculate_mission_reward(
			signal_data,
			self.current_target_index )
