extends Marker3D
class_name TargetVector

const RADIUS_FROM_LANDER: float = 10.0
@onready var lander: RigidBody3D = self.get_parent()
var mission: MissionController = null
var mission_target := Vector3.ZERO

func _ready() -> void:
	Signals.target_assigned.connect(_update_mission_target)

func _process(_delta: float) -> void:
	self.visible = mission_target != Vector3.ZERO
	if mission == null:
		push_warning("No mission controller set.")
		return
	_point_towards_target(mission_target)

func _point_towards_target(target: Vector3) -> void:
	var direction = lander.global_position.direction_to(target)
	self.global_position = lander.global_position + direction * RADIUS_FROM_LANDER
	self.look_at(target, Vector3(0,1,0), true)

func _distance_to_target(target: Vector3) -> float:
	return lander.global_position.distance_to(target)

func _update_mission_target(signal_data: Vector3) -> void:
	print("Mission target updated for HUD", str(signal_data))
	self.mission_target = signal_data

func set_mission(mission_controller: MissionController) -> void:
	self.mission = mission_controller
