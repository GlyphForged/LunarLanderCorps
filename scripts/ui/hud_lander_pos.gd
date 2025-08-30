extends Label

var lander: RigidBody3D

func _process(_delta):
	if lander:
		var vel: Vector3 = lander.linear_velocity

		var h_vel := Vector2(vel.x, vel.z).length()
		var v_vel: float = abs(vel.y)
		var dmg: float = lander.current_damage

		text = "Horizontal Speed: %4.2f | \
				Vertical Speed: %4.2f\n\
				Current Damage: %4.2f / 10.0| \
				Score: %d | \
				Current Fuel: %4.2f / %4.2f" % \
		[
			h_vel,
			v_vel,
			dmg,
			lander.total_score,
			lander.current_fuel,
			lander.max_fuel,
		]
	else:
		lander = get_tree().get_first_node_in_group("lander")
