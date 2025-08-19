class_name TerrainChunk
extends MeshInstance3D

const TERRAIN_SIZE := 100
const CENTER_OFFSET = 0.5

@export var max_terrain_height := 5
@export var chunk_lods: Array[int] = [2, 4, 8, 15, 20, 50]
@export var LOD_distances: Array[int] = [2000, 1500, 1050, 900, 790, 550]
var resolution := 20
var set_collision := false

var position_coord: Vector2
var grid_coord: Vector2

func generate_terrain(
	noise: FastNoiseLite,
	coords: Vector2,
	init_visible: bool
):
	grid_coord = coords
	position_coord = coords * TERRAIN_SIZE

	var a_mesh: ArrayMesh
	var surftool = SurfaceTool.new()
	surftool.begin(Mesh.PRIMITIVE_TRIANGLES)

	for z in resolution+1:
		for x in resolution+1:
			var percent = Vector2(x,z) / resolution
			var pt_on_mesh = Vector3(
				(percent.x - CENTER_OFFSET),
				0,
				(percent.y - CENTER_OFFSET)
			)
			var vertex = pt_on_mesh * TERRAIN_SIZE
			vertex.y = noise.get_noise_2d(
				position.x + vertex.x,
				position.z + vertex.z
			) * max_terrain_height
			var uv := Vector2(percent.x, percent.y)
			surftool.set_uv(uv)
			surftool.add_vertex(vertex)
	var vert = 0

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
	surftool.generate_normals()
	a_mesh = surftool.commit()
	mesh = a_mesh

	if set_collision:
		create_collision()
	setChunkVisible(init_visible)

func create_collision():
	if get_child_count() > 0:
		get_child(0).queue_free()
	create_trimesh_collision()

func update_chunk(view_pos:Vector2,max_view_dis):
	var viewer_distance = position_coord.distance_to(view_pos)
	var _is_visible = viewer_distance <= max_view_dis

#SLOW
func should_remove(view_pos:Vector2,max_view_dis):
	var remove = false
	var viewer_distance = position_coord.distance_to(view_pos)
	if viewer_distance > max_view_dis:
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

	if new_lod >= chunk_lods[chunk_lods.size()-1]:
		set_collision = true
	else:
		set_collision = false

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
