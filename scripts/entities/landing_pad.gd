extends StaticBody3D

@onready var collider: CollisionShape3D = $pad_collider
@onready var mesh: MeshInstance3D = $pad_mesh

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

func on_save_game(saved_data:Array[SaveData]) -> void:
	var pad_data = SaveData.new()
	pad_data.position = self.global_position
	pad_data.scene_path = scene_file_path
	saved_data.append(pad_data)

func on_before_load_game() -> void:
	get_parent().remove_child(self)
	self.queue_free()

func on_load_game(saved_data:SaveData):
	self.global_position = saved_data.position
