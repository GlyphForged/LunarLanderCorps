@tool
extends MeshInstance3D

# Default to 20 width then update post-spawn
@export var width: float = 20.0:
	get: return width
	set(val):
		width = val
		_update_size(val)

func _update_size(val) -> void:
	mesh.size = Vector3(val, 0.5, val)
