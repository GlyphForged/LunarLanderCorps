class_name TerrainGenerator

extends Node3D

var chunk_mesh_scene = preload(Util.CHUNK_ID)

const TERRAIN_HEIGHT = 15
const CHUNK_SIZE = 1000
@export var view_distance = 1000
@export var render_debug := false
var viewer_position = Vector2()
var terrain_chunks = {}
var chunksvisible=0

var last_visible_chunks = []
var noise0 := FastNoiseLite.new()
var noise1 := FastNoiseLite.new()

func _ready():
	#set the total chunks to be visible
	@warning_ignore("integer_division")
	chunksvisible = roundi(view_distance/CHUNK_SIZE)
	if render_debug:
		set_wireframe()
	# == NOISE FUCKERY ===
	noise0.noise_type = FastNoiseLite.TYPE_CELLULAR
	noise1.noise_type = FastNoiseLite.TYPE_VALUE_CUBIC

func set_wireframe():
	RenderingServer.set_debug_generate_wireframes(true)
	get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME

func _process(_delta):
	viewer_position.x = 0
	viewer_position.y = 0
	updateVisibleChunk()

func updateVisibleChunk():
	#get grid position
	var currentX = roundi(viewer_position.x/CHUNK_SIZE)
	var currentY = roundi(viewer_position.y/CHUNK_SIZE)
	#get all the chunks within visiblity range
	if not (currentX < -1 or \
			currentX > 1 or \
			currentY < -1 or \
			currentY > 1):
		for yOffset in range(-1,2):
			for xOffset in range(-1,2):
				#create a new chunk coordinate
				var view_chunk_coord = Vector2(currentX-xOffset,currentY-yOffset)
				#check if chunk was already created
				if terrain_chunks.has(view_chunk_coord):
					terrain_chunks[view_chunk_coord].update_chunk(viewer_position,view_distance)
					if terrain_chunks[view_chunk_coord].update_lod(viewer_position):
						terrain_chunks[view_chunk_coord].generate_terrain(CHUNK_SIZE, TERRAIN_HEIGHT,noise0, noise1, view_chunk_coord,true)
				else:
					var chunk: TerrainChunk = chunk_mesh_scene.instantiate()
					chunk.name = "chunk_%d_%d" % [xOffset, yOffset]
					add_child(chunk)
					print("Added ", chunk.name)
					#set chunk parameters
					chunk.max_terrain_height = TERRAIN_HEIGHT
					#set chunk world position
					var pos = view_chunk_coord*CHUNK_SIZE
					var world_position = Vector3(pos.x,0,pos.y)
					chunk.global_position = world_position
					chunk.generate_terrain(CHUNK_SIZE,TERRAIN_HEIGHT, noise0, noise1, view_chunk_coord,false)
					terrain_chunks[view_chunk_coord] = chunk

func on_save_game() -> void:
	DirAccess.make_dir_recursive_absolute("user://chunks")
	for coord: Vector2 in terrain_chunks.keys():
		var node := terrain_chunks[coord] as Node
		if node == null or not is_instance_valid(node):
			continue
		var path := _chunk_path(Vector2i(coord))
		save_as_scene(node, path)

func on_before_load_game() -> void:
	for node in terrain_chunks.values():
		if node and is_instance_valid(node):
			node.queue_free()

	terrain_chunks.clear()
	last_visible_chunks.clear()

func on_load_game() -> void:
	var dir := DirAccess.open("user://chunks")
	if dir == null:
		# Nothing cached yet
		return

	dir.list_dir_begin()
	while true:
		var fname := dir.get_next()
		if fname == "":
			break
		if dir.current_is_dir():
			continue
		if not fname.ends_with(".scn"):
			continue

		var path := "user://chunks/%s" % fname
		var ps := load(path)
		if ps is PackedScene:
			var inst := (ps as PackedScene).instantiate()
			add_child(inst)

			# Rebuild the dictionary key from filename
			var grid := _coord_from_filename(path)      # Vector2i
			var key  := Vector2(grid.x, grid.y)        # match your map’s Vector2 keys
			terrain_chunks[key] = inst
	dir.list_dir_end()

func get_height_at_position(pos: Vector2) -> float:
	var temp_y = noise0.get_noise_2d(pos.x, pos.y) * TERRAIN_HEIGHT
	temp_y *= noise1.get_noise_2d(pos.x, pos.y) * TERRAIN_HEIGHT
	return temp_y

func save_as_scene(node: Node, path: String) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())

	var packed := PackedScene.new()
	var ok := packed.pack(node)
	if ok != OK:
		push_error("Failed to pack: %s" % node.name)
		return

	var out_path := path.get_basename() + ".scn"
	var flags := ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS \
			   | ResourceSaver.FLAG_OMIT_EDITOR_PROPERTIES
	var err := ResourceSaver.save(packed, out_path, flags)
	if err != OK:
		push_error("Failed saving %s: %s" % [out_path, err])

func _chunk_path(coord: Vector2i) -> String:
	return "user://chunks/%d_%d.scn" % [coord.x, coord.y]

func _coord_from_filename(path: String) -> Vector2i:
	var base := path.get_file().get_basename() # "x_y"
	var parts := base.split("_")
	if parts.size() != 2:
		return Vector2i.ZERO
	return Vector2i(int(parts[0]), int(parts[1]))
