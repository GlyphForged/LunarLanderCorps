extends Node3D

const PAUSE_MENU = preload(Util.PAUSE_ID)
const CAM_RIG = preload(Util.CAM_RIG_ID)
const LANDER_SCENE = preload(Util.LANDER_ID)
const INF_TERRAIN = preload(Util.INF_TERRAIN_ID)

var paused: bool

func _ready() -> void:
	self.paused = false
	var lander = LANDER_SCENE.instantiate()
	get_node(".").add_child.call_deferred(lander)
	lander.add_to_group("lander")

	var cam_rig = CAM_RIG.instantiate() as CameraRig
	get_node(".").add_child.call_deferred(cam_rig)
	cam_rig.call_deferred("set_lander", lander)
	cam_rig.add_to_group("cam")

	var infinite_terrain = INF_TERRAIN.instantiate() as TerrainGenerator
	get_node(".").add_child.call_deferred(infinite_terrain)
	infinite_terrain.call_deferred("set_lander", lander)

func _process(_delta) -> void:
	_handle_pause_input()

func _handle_pause_input() -> void:
	Util.mouse_mode_cache = Input.mouse_mode
	if Input.is_action_just_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true
		var pause_menu = PAUSE_MENU.instantiate()
		get_node(".").add_child(pause_menu)
