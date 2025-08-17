extends Label

@export var lander: Node3D
@onready var lander_bod = lander.get_child(0)

func _process(_delta):
	if lander:
		var pos: Vector3 = lander_bod.global_transform.origin
		var vel: Vector3 = lander_bod.linear_velocity

		var h_vel := Vector2(vel.x, vel.z).length()
		var v_vel: float = abs(vel.y)

		text = "POS: %4.2f, %4.2f\nH_SPD: %4.2f\nV_SPD: %4.2f" % [pos.x, pos.z, h_vel, v_vel]
