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
	for n in 5:
		var pad = LANDING_PAD.instantiate()
		pad.name = "landing-pad-%d" % n
		add_child(pad)
		var w = randf_range(MIN_WIDTH, MAX_WIDTH)
		pad.width = w
		var position := Vector2(0., 0.)
		match n:
			1:
				position.x += randf_range(MIN_DISTANCE, MAX_DISTANCE)
			2:
				position.x -= randf_range(MIN_DISTANCE, MAX_DISTANCE)
			3:
				position.y += randf_range(MIN_DISTANCE, MAX_DISTANCE)
			4:
				position.y -= randf_range(MIN_DISTANCE, MAX_DISTANCE)
			_:
				pass
		var height: Array[float]
		print(pad.name, " | Height: ", height)
		var altitude = _get_ideal_altitude(w, position, ground) + randf_range(MIN_ALT, MAX_ALT)
		pad.transform.origin = Vector3(position.x, altitude, position.y)

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
