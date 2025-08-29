extends Marker3D
class_name TargetVector

const RADIUS_FROM_LANDER: float = 10.0
const PAD_HIDE_OUTER_RADIUS: float = 300.0
const PAD_HIDE_INNER_RADIUS: float = 100.0
@onready var lander: RigidBody3D = self.get_parent()
@onready var shaft: MeshInstance3D = $"3DArrow/Shaft"

var dist_cache := 0.0
var mission: MissionController = null
var mission_target := Vector3.ONE

func _ready() -> void:
	Signals.target_assigned.connect(_update_mission_target)

func _process(_delta: float) -> void:
	self.visible = mission_target != Vector3.ONE
	if mission == null:
		push_warning("No mission controller set.")
		return
	_point_towards_target(mission_target)
	_set_alpha()

func _point_towards_target(target: Vector3) -> void:
	var direction = lander.global_position.direction_to(target)
	self.global_position = lander.global_position + direction * RADIUS_FROM_LANDER
	self.look_at(target, Vector3.UP, true)

func _set_alpha() -> void:
	var mat: StandardMaterial3D = shaft.get_active_material(0)
	var distance = lander.global_position.distance_to(mission_target)
	if distance < PAD_HIDE_OUTER_RADIUS and distance > PAD_HIDE_INNER_RADIUS:
		var ratio = (distance - PAD_HIDE_INNER_RADIUS) / (PAD_HIDE_OUTER_RADIUS - PAD_HIDE_INNER_RADIUS)
		mat.albedo_color.a = ratio / 2.0
	elif distance < PAD_HIDE_INNER_RADIUS:
		mat.albedo_color.a = 0
	else:
		mat.albedo_color.a = 0.5

func _distance_to_target(target: Vector3) -> float:
	return lander.global_position.distance_to(target)

func _update_mission_target(signal_data: Vector3) -> void:
	self.mission_target = signal_data

func set_mission(mission_controller: MissionController) -> void:
	self.mission = mission_controller
