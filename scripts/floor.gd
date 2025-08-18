extends CSGBox3D

var ignored_bodies = [
	"map",
	"floor"
]

func _on_area_lander_entered(body: Node3D) -> void:
	if ignored_bodies.has(body.name):
		return
	if !is_instance_of(body, RigidBody3D):
		return
	print(body.linear_velocity)
	print(body.get_colliding_bodies())
