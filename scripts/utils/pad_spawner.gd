class_name PadSpawner

extends Node

const LANDING_PAD: PackedScene = preload("res://scenes/entities/landing_pad.tscn")
const MAX_WIDTH: float = 30.0
const MIN_WIDTH: float = 15.0
const MAX_ALT: float = 6.0
const MIN_ALT: float = 3.0
const MIN_DISTANCE: float = 200.0
const MAX_DISTANCE: float = 500.0

@onready var ground: TerrainGenerator = %infinite_terrain

func _ready() -> void:
	var sampler = PoissonSampler.new()
	var positions = sampler.generate_poisson_pts(200.0, 12)

	for pos in positions:
		var pad = LANDING_PAD.instantiate()
		pad.name = "landing-pad-%s" % str(pos)
		self.add_child(pad)
		var w = randf_range(MIN_WIDTH, MAX_WIDTH)
		pad.width = w
		var height: Array[float]
		print(pad.name, " | Height: ", height)
		var altitude = _get_ideal_altitude(w, pos, ground) + randf_range(MIN_ALT, MAX_ALT)
		pad.transform.origin = Vector3(pos.x, altitude, pos.y)

func _get_ideal_altitude(
	w: float,
	pos: Vector2,
	grnd: TerrainGenerator
) -> float:
	var h_w = w / 2.0
	var pts: Array[float] = [
		grnd.get_height_at_position(Vector2(pos.x - h_w, pos.y - h_w)),
		grnd.get_height_at_position(Vector2(pos.x,       pos.y - h_w)),
		grnd.get_height_at_position(Vector2(pos.x + h_w, pos.y - h_w)),
		grnd.get_height_at_position(Vector2(pos.x - h_w, pos.y)),
		grnd.get_height_at_position(pos),
		grnd.get_height_at_position(Vector2(pos.x + h_w, pos.y)),
		grnd.get_height_at_position(Vector2(pos.x - h_w, pos.y + h_w)),
		grnd.get_height_at_position(Vector2(pos.x,       pos.y + h_w)),
		grnd.get_height_at_position(Vector2(pos.x + h_w, pos.y + h_w)),
	]
	return pts.max()
