extends Node

class_name PoissonSampler

func generate_poisson_pts(radius: float, max_pts: int = 12, k: int = 30) -> Array[Vector2]:
	var w: float = radius / sqrt(2)
	var pts: Array[Vector2] = []
	var active: Array[Vector2] = []
	var grid: Dictionary = {}

	var origin := Vector2(0,0)
	var origin_key: Vector2 = _grid_key(origin, w)
	grid[origin_key] = origin
	active.append(origin)
	pts.append(origin)

	while active.size() > 0 and pts.size() < max_pts:
		var rand_index = randi() % active.size()
		var pos = active[rand_index]
		var found = false

		for i in k:
			var angle = randf() * TAU
			var mag = randf_range(radius, 2 * radius)
			var sample = pos + Vector2(cos(angle), sin(angle)) * mag
			var sample_key = _grid_key(sample, w)

		# Check if cell is empty
			if grid.has(sample_key):
				continue

			var ok = true
		# Check neighboring cells
			for dx in range(-1, 2):
				for dy in range(-1, 2):
					var neighbor_key = sample_key + Vector2(dx, dy)
					if grid.has(neighbor_key):
						var neighbor = grid[neighbor_key]
						if sample.distance_to(neighbor) < radius:
							ok = false
							break
				if not ok:
					break

			if ok:
				grid[sample_key] = sample
				active.append(sample)
				pts.append(sample)
				found = true
				break

		if not found:
			active.remove_at(rand_index)

	return pts

func _grid_key(pos: Vector2, w: float) -> Vector2:
	return Vector2(floor(pos.x / w), floor(pos.y / w))
