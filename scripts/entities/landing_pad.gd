class_name LandingPad
extends Node3D

const LANDING_PAD_LARGE = preload("res://scenes/entities/landing_pad_large.tscn")
const LANDING_PAD_MEDIUM = preload("res://scenes/entities/landing_pad_medium.tscn")
const LANDING_PAD_SMALL = preload("res://scenes/entities/landing_pad_small.tscn")
const SAFE_LANDING_VEL: float = 5.0
const MAX_ALT: float = 5.0
const MIN_ALT: float = 3.0
@onready var landing_area: Area3D = $Pad/LandingArea
var last_coll_time = Time.get_ticks_msec()

func _ready() -> void:
	landing_area.body_shape_entered.connect(_on_landing_pad_entered)

func on_save_game(saved_data:Array[SaveData]) -> void:
	var pad_data = SaveData.new()
	pad_data.position = self.global_position
	pad_data.scene_path = scene_file_path
	saved_data.append(pad_data)

func on_before_load_game() -> void:
	get_parent().remove_child(self)
	self.queue_free()

func on_load_game(pad_data:SaveData):
	self.global_position = pad_data.position
	self.add_to_group("landing_pads")
	self.add_to_group("game_events")

func _on_landing_pad_entered(_body_rid: RID, body: Node3D, body_shape_index: int, _local_shape_index: int) -> void:
	var curr_time = Time.get_ticks_msec()
	if curr_time - last_coll_time > 1000:
		#print(body.name, " landed with ", body_shape_index, " touching")
		if body.linear_velocity.length() < 0.1:
			if body_shape_index < 4 \
			and abs(body.velocity_cache.y) < SAFE_LANDING_VEL:
				print("Safe landing!")
				print(abs(body.velocity_cache.y))
				Signals.landed_safely.emit(self.get_index())
				last_coll_time = Time.get_ticks_msec()
			else:
				print("Crash landing!")
				print(abs(body.velocity_cache.y))
				last_coll_time = Time.get_ticks_msec()

func _on_landing_pad_exited(_body_rid: RID, _body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	pass #not sure we need this signal yet, tbh
	#print(body, " exited ", self.get_index(), " @ ", str(self.global_position))

static func get_scene_path(difficulty: Util.PAD_DIFFICULTY) -> String:
	match difficulty:
		Util.PAD_DIFFICULTY.EASY:
			return Util.LANDING_PAD_LARGE_ID
		Util.PAD_DIFFICULTY.NORMAL:
			return Util.LANDING_PAD_MEDIUM_ID
		Util.PAD_DIFFICULTY.HARD:
			return Util.LANDING_PAD_SMALL_ID
		_:
			return ""

static func create_landing_pad(
	difficulty: Util.PAD_DIFFICULTY,
	ground: TerrainGenerator,
	pos: Vector2
) -> LandingPad:
	var scene_path = get_scene_path(difficulty)
	if scene_path == "":
		push_error("Invalid difficulty passed in to create_landing_pad in landing_pad.gd")
	if !FileAccess.file_exists(scene_path):
		push_error("Scene for ", difficulty, " not found.")
	var pad_scene = load(scene_path)
	var pad = pad_scene.instantiate()
	var altitude = get_ideal_altitude(35.0, pos, ground) + randf_range(MIN_ALT, MAX_ALT)
	pad.transform.origin = Vector3(pos.x, altitude, pos.y)
	pad.add_to_group("landing_pads")
	pad.add_to_group("game_events")
	return pad

static func get_ideal_altitude(
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
