class_name TerrainChunk
extends MeshInstance3D

const TERRAIN_SIZE := 1250
const CENTER_OFFSET = 0.5

@export var max_terrain_height := 15
@export var chunk_lods: Array[int] = [20, 40, 80, 150, 200, 500]
@export var LOD_distances: Array[int] = [20000, 15000, 10500, 9000, 7900, 5500]
var resolution := 400

var position_coord: Vector2
var grid_coord: Vector2

func generate_terrain(
	terrain_size,
	terrain_height,
	noise0: FastNoiseLite,
	noise1: FastNoiseLite,
	coords: Vector2,
	init_visible: bool
):
	grid_coord = coords
	position_coord = coords * terrain_size

	var a_mesh: ArrayMesh
	var surftool = SurfaceTool.new()
	print("surftool begin")
	surftool.begin(Mesh.PRIMITIVE_TRIANGLES)

	for z in resolution+1:
		for x in resolution+1:
			var percent = Vector2(x,z) / resolution
			var pt_on_mesh = Vector3(
				(percent.x - CENTER_OFFSET),
				0,
				(percent.y - CENTER_OFFSET)
			)
			var vertex = pt_on_mesh * terrain_size
			var temp_y = noise0.get_noise_2d(
				position.x + vertex.x,
				position.z + vertex.z
			) * terrain_height
			temp_y *= noise1.get_noise_2d(
				position.x + vertex.x,
				position.z + vertex.z
			) * terrain_height
			vertex.y = temp_y
			var uv := Vector2(percent.x, percent.y)
			surftool.set_uv(uv)
			surftool.add_vertex(vertex)
	var vert = 0

	print("vertices created")
	for z in resolution:
		for x in resolution:
			surftool.add_index(vert)
			surftool.add_index(vert+1)
			surftool.add_index(vert+resolution+1)
			surftool.add_index(vert+resolution+1)
			surftool.add_index(vert+1)
			surftool.add_index(vert+resolution+2)
			vert+=1
		vert+=1
	print("indices created")
	print("making normals")
	surftool.generate_normals()
	print("comitting")
	a_mesh = surftool.commit()
	mesh = a_mesh

	print("making colliding")
	create_collision()
	setChunkVisible(init_visible)

func create_collision():
	if get_child_count() > 0:
		get_child(0).queue_free()
	create_trimesh_collision()

func update_chunk(view_pos:Vector2,max_view_dis):
	var viewer_distance = position_coord.distance_to(view_pos)
	var _is_visible = viewer_distance <= max_view_dis
	print(_is_visible)
	return _is_visible

func should_remove(terrain_size,view_pos:Vector2, max_view_dis):
	var remove = false
	var viewer_distance = view_pos.distance_to(position_coord) - (terrain_size * 3)
	if viewer_distance > max_view_dis:
		print("Chunk removal: ", viewer_distance, "Chunk: ", grid_coord)
		remove = true
	return remove

func update_lod(view_pos:Vector2):
	var viewer_distance = position_coord.distance_to(view_pos)
	var update_terrain = false
	var new_lod = chunk_lods[0]

	if chunk_lods.size() != LOD_distances.size():
		print("ERROR Lods and Distance count mismatch")
		return

	for i in range(chunk_lods.size()):
		var lod = chunk_lods[i]
		var dis = LOD_distances[i]
		if viewer_distance < dis:
			new_lod = lod

	if resolution != new_lod:
		resolution = new_lod
		update_terrain = true
	return update_terrain

func setChunkVisible(_is_visible):
	visible = _is_visible

func getChunkVisible():
	return visible

func free_chunk():
	queue_free()
