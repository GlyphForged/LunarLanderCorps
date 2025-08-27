class_name TerrainGenerator

extends Node3D

# This breaks with how we create the lander now.
#@onready var lander: RigidBody3D = get_tree().get_first_node_in_group("lander")
var lander: RigidBody3D
var chunk_mesh_scene = preload(Util.CHUNK_ID)

const TERRAIN_HEIGHT = 15
const CHUNK_SIZE = 100
@export var view_distance = 500
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

func set_lander(new_lander: RigidBody3D) -> void:
	lander = new_lander

func set_wireframe():
	RenderingServer.set_debug_generate_wireframes(true)
	get_viewport().debug_draw = Viewport.DEBUG_DRAW_WIREFRAME

func _process(_delta):
	if is_instance_valid(lander):
		viewer_position.x = lander.global_position.x
		viewer_position.y = lander.global_position.z
		updateVisibleChunk()

func updateVisibleChunk():
	var currentX = roundi(viewer_position.x/CHUNK_SIZE)
	var currentY = roundi(viewer_position.y/CHUNK_SIZE)
	#get all the chunks within visiblity range
	for yOffset in range(-chunksvisible,chunksvisible):
		for xOffset in range(-chunksvisible,chunksvisible):
			#create a new chunk coordinate
			var view_chunk_coord = Vector2(currentX-xOffset,currentY-yOffset)
			#check if chunk was already created
			if terrain_chunks.has(view_chunk_coord):
				#print("Found chunk ", view_chunk_coord)
				#var ref = weakref(terrain_chunks[view_chunk_coord])
				#if chunk exist update the chunk passing viewer_position and view_distance
				terrain_chunks[view_chunk_coord].update_chunk(viewer_position,view_distance)
				if terrain_chunks[view_chunk_coord].update_lod(viewer_position):
					terrain_chunks[view_chunk_coord].generate_terrain(noise0, noise1, view_chunk_coord,true)
				#if chunk is visible add it to last visible chunks
#				if terrain_chunks[view_chunk_coord].getChunkVisible():
#					last_visible_chunks.append(terrain_chunks[view_chunk_coord])
			else:
				#print(view_chunk_coord)
			#if chunk doesnt exist, create chunk
				var chunk :TerrainChunk= chunk_mesh_scene.instantiate()
				chunk.name = "chunk_%d_%d" % [xOffset, yOffset]
				add_child(chunk)
				print("Added ", chunk.name)
				#set chunk parameters
				chunk.max_terrain_height = TERRAIN_HEIGHT
				#set chunk world position
				var pos = view_chunk_coord*CHUNK_SIZE
				var world_position = Vector3(pos.x,0,pos.y)
				chunk.global_position = world_position
				chunk.generate_terrain(noise0, noise1, view_chunk_coord,false)
				terrain_chunks[view_chunk_coord] = chunk
#check if we should remove chunk from scene
	for chunk in get_children():
		if chunk.should_remove(viewer_position,view_distance):
			chunk.queue_free()
			if terrain_chunks.has(chunk.grid_coord):
				terrain_chunks.erase(chunk.grid_coord)

func get_height_at_position(pos: Vector2) -> float:
	var temp_y = noise0.get_noise_2d(pos.x, pos.y) * TERRAIN_HEIGHT
	temp_y *= noise1.get_noise_2d(pos.x, pos.y) * TERRAIN_HEIGHT
	return temp_y

func get_active_threads():
	#This version isnt using
	#threading so return 0
	return 0
