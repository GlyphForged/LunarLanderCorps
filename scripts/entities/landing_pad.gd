extends StaticBody3D

@onready var collider: CollisionShape3D = $pad_collider
@onready var mesh: MeshInstance3D = $pad_mesh
@onready var area_collider: CollisionShape3D = $Area3D/area_collider
const SAFE_LANDING_VEL: float = 3.0
var last_coll_time = Time.get_ticks_msec()

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
	area_collider.width = val


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


func _on_landing_pad_entered(_body_rid: RID, body: Node3D, body_shape_index: int, _local_shape_index: int) -> void:
	var curr_time = Time.get_ticks_msec()
	if curr_time - last_coll_time > 500:
		#print(body.name, " landed with ", body_shape_index, " touching")
		if body_shape_index < 4 and abs(body.velocity_cache.y) < SAFE_LANDING_VEL:
			print("Safe landing!")
			print(abs(body.velocity_cache.y))
		else:
			print("Crash landing!")
			print(abs(body.velocity_cache.y))
		last_coll_time = Time.get_ticks_msec()
	Signals.landed_safely.emit(self.get_index())


func _on_landing_pad_exited(_body_rid: RID, _body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	pass #not sure we need this signal yet, tbh
	#print(body, " exited ", self.get_index(), " @ ", str(self.global_position))
