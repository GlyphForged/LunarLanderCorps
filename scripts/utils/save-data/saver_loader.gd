extends Node
class_name SaverLoader

@onready var game_node = get_tree().root.get_node("Game")
@onready var pad_spawner = get_tree().root.get_node("Game/pad_spawner")

func _ready() -> void:
	Signals.save_game_clicked.connect(_save_game)
	Signals.load_game_clicked.connect(_load_game)

func _save_game() -> void:
	var saved_game := SavedGame.new()

	# Start with blank data
	var lander_data := LanderData.new()
	var cam_data := SaveData.new()
	var pad_data: Array[SaveData]
	var mission_data := MissionData.new()

	# Fire the signal to ask folks to save their data
	get_tree().call_group("lander", "on_save_game", lander_data)
	saved_game.lander_data = lander_data
	get_tree().call_group("landing_pads", "on_save_game", pad_data)
	saved_game.pad_data = pad_data
	get_tree().call_group("cam", "on_save_game", cam_data)
	saved_game.cam_data = cam_data
	get_tree().call_group("mission_gen", "on_save_game", mission_data)
	saved_game.mission_data = mission_data
	get_tree().call_group("terrain_gen", "on_save_game")

	var err = ResourceSaver.save(saved_game, "user://savegame.tres")
	if err != OK:
		push_error("Something went wrong: ", err)

func _load_game() -> void:
	var saved_game = ResourceLoader.load("user://savegame.tres") as SavedGame
	if saved_game == null:
		return

	get_tree().call_group("game_events", "on_before_load_game")
	get_tree().call_group("terrain_gen", "on_load_game")
	get_tree().call_group("lander", "on_load_game", saved_game.lander_data)
	get_tree().call_group("cam", "on_load_game", saved_game.cam_data)
	get_tree().call_group("mission_gen", "on_load_game", saved_game.mission_data)

	# Restore Landing Pad Data
	for pad_data in saved_game.pad_data:
		var scene := load(pad_data.scene_path)
		var restored_node = scene.instantiate()
		# Add it to the pad spawner node
		if pad_spawner:
			pad_spawner.add_child(restored_node)
		if restored_node.has_method("on_load_game"):
			restored_node.on_load_game(pad_data)
