@tool
extends StaticBody3D

@onready var collider: CollisionShape3D = $pad_collider
@onready var mesh: MeshInstance3D = $pad_mesh
#@onready var ground:

@export var width: float = 20.0:
	get: return width
	set(val):
		width = val
		_update_child_width(val)

func _ready() -> void:
	_update_child_width(width)

func _update_child_width(val: float) -> void:
	collider.width = val
	mesh.width = val
