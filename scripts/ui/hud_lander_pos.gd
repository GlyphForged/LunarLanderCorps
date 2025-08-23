extends Label

@export var lander: RigidBody3D

func _process(_delta):
	if lander:
		var pos: Vector3 = lander.global_transform.origin
		var vel: Vector3 = lander.linear_velocity

		var h_vel := Vector2(vel.x, vel.z).length()
		var v_vel: float = abs(vel.y)
		var dmg: float = lander.current_damage

		text = "POS: %4.2f, %4.2f\nH_SPD: %4.2f\nV_SPD: %4.2f\nDMG: %4.2f\nFPS: %2d" % [
			pos.x,
			pos.z,
			h_vel,
			v_vel,
			dmg,
			Engine.get_frames_per_second()
		]
