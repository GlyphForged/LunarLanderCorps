extends Label

var lander: RigidBody3D

func _process(_delta):
	if lander:
		var pos: Vector3 = lander.global_transform.origin
		var vel: Vector3 = lander.linear_velocity

		var h_vel := Vector2(vel.x, vel.z).length()
		var v_vel: float = abs(vel.y)
		var dmg: float = lander.current_damage

		text = "POS: %4.2f, %4.2f | \
				H_SPD: %4.2f | \
				V_SPD: %4.2f\n\
				DMG: %4.2f | \
				SCORE: %d | \
				FUEL: %4.2f | \
				FPS: %2d" % [
			pos.x,
			pos.z,
			h_vel,
			v_vel,
			dmg,
			lander.total_score,
			lander.current_fuel,
			Engine.get_frames_per_second()
		]
	else:
		lander = get_tree().get_first_node_in_group("lander")
