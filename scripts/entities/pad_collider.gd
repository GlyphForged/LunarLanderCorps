@tool
extends CollisionShape3D

@export var width: float = 20.0:
	get: return width
	set(val):
		width = val
		_update_width(val)

func _update_width(val):
	shape.size = Vector3(val, 0.5, val)
