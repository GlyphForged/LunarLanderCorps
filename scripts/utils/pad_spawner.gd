class_name PadSpawner

extends Node

const LANDING_PAD: PackedScene = preload("res://scenes/entities/landing_pad.tscn")
const MAX_WIDTH: float = 30.0
const MIN_WIDTH: float = 15.0
const RADIUS: float = 250.0
const COUNT: int = 12

var ground: TerrainGenerator = null

func _ready() -> void:
	ground = get_parent().get_child(4)
	var sampler = PoissonSampler.new()
	var positions = sampler.generate_poisson_pts(RADIUS, COUNT)
	# send loadables signal here

	var diff_index := 0
	for pos in positions:
		var difficulty_array = _build_difficulty_array(COUNT)
		self.add_child(LandingPad.create_landing_pad(
			difficulty_array[diff_index],
			ground,
			pos))
		diff_index += 1
		# send loaded one signal here

func _build_difficulty_array(num: int) -> Array[Util.PAD_DIFFICULTY]:
	var difficulty_array: Array[Util.PAD_DIFFICULTY] = []
	var easy_ratio = 0.5
	var normal_ratio = 0.35
	var hard_ratio = 0.15
	var num_easy = floor(num * easy_ratio)
	var num_normal = floor(num * normal_ratio)
	var num_hard = floor(num * hard_ratio)
	if num_easy + num_normal + num_hard < num:
		num_normal += num - (num_easy + num_normal + num_hard)
	for n in num_easy:
		difficulty_array.append(Util.PAD_DIFFICULTY.EASY)
	for n in num_normal:
		difficulty_array.append(Util.PAD_DIFFICULTY.NORMAL)
	for n in num_hard:
		difficulty_array.append(Util.PAD_DIFFICULTY.HARD)
	return difficulty_array
