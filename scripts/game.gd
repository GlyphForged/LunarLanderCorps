extends Node3D

const PAUSE_MENU = preload(Util.PAUSE_ID)
const CAM_RIG = preload(Util.CAM_RIG_ID)
const LANDER = preload(Util.LANDER_ID)
const INF_TERRAIN = preload(Util.INF_TERRAIN_ID)
const PAD_SPAWNER = preload(Util.PAD_SPAWNER_ID)
const MISSION_CONTROLLER = preload(Util.MISSION_CONTROLLER_ID)
const SAVER_LOADER = preload(Util.SAVER_LOADER_ID)
const JUKEBOX = preload(Util.JUKEBOX_ID)
const CRT = preload(Util.CRT_ID)

var paused: bool
var upgrade_timer := Time.get_ticks_msec()

var added_scenes: Dictionary = {}
var lander_instance = null
var everything_added: bool = false

func add_scene(preloaded_scene, scene_name):
	var live_scene = preloaded_scene.instantiate()
	get_node(".").add_child(live_scene)
	added_scenes.set(scene_name, true)
	live_scene.add_to_group(scene_name)
	return live_scene

func rig_camera(lander):
	var cam_rig = CAM_RIG.instantiate() as CameraRig
	get_node(".").add_child.call_deferred(cam_rig)
	cam_rig.call_deferred("set_lander", lander)
	cam_rig.add_to_group("cam")
	added_scenes.set("cam", true)

func _ready() -> void:
	Signals.landed_on_target_pad.connect(_spawn_upgrade_popup)
	%DebugHud.visible = false
	$Loading.visible = true
	self.paused = false

func _process(_delta) -> void:
	if not everything_added:
		if not added_scenes.get("zero"):
			added_scenes.set("zero", true)
			update_text("reticulating splines")
		elif not added_scenes.get("inf_terrain"):
			add_scene(INF_TERRAIN, "inf_terrain")
			update_text("getting heading")
		elif not added_scenes.get("pad_spawner"):
			add_scene(PAD_SPAWNER, "pad_spawner")
			update_text("contacting mission control")
		elif not added_scenes.get("mission_controller"):
			add_scene(MISSION_CONTROLLER, "mission_controller")
			update_text("opening pod bay doors")
		elif not added_scenes.get("lander"):
			lander_instance = add_scene(LANDER, "lander")
			update_text("calibrating retro encabulator")
		elif not added_scenes.get("cam"):
			rig_camera(lander_instance)
			update_text("bargaining with death")
		elif not added_scenes.get("saver_loader"):
			update_text("get ready")
			add_scene(SAVER_LOADER, "saver_loader")
		elif not added_scenes.get("jukebox"):
			update_text("turning on the radio")
			add_scene(JUKEBOX, "jukebox")
		elif not added_scenes.get("crt"):
			update_text("booting hyperencabulator")
			add_scene(CRT, "crt")
		else:
			everything_added = true
			$Loading.visible = false
			$Loading.queue_free()
			self.paused = false
			%DebugHud.visible = true

	_handle_pause_input()


func update_text(input):
	$Loading.set_text(input)

func _handle_pause_input() -> void:
	Util.mouse_mode_cache = Input.mouse_mode
	if Input.is_action_just_pressed("pause") and !self.paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true
		var pause_menu = PAUSE_MENU.instantiate()
		get_node(".").add_child(pause_menu)

func _spawn_upgrade_popup() -> void:
	Util.mouse_mode_cache = Input.mouse_mode
	if Time.get_ticks_msec() - upgrade_timer > 1500:
		var upgrade_popup = preload(Util.UPGRADE_POPUP_ID).instantiate()
		self.add_child(upgrade_popup)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
