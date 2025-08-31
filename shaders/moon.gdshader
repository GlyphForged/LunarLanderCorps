shader_type spatial;

uniform float line_thickness : hint_range(0.0, 2.0, 0.01) = 1.0;
uniform float line_interval : hint_range(0.01, 100.0, 0.01) = 0.25;
uniform vec3 line_color : source_color = vec3(0.9, 0.6, 0.2);
uniform sampler2D noise_texture;
uniform float intensity = 0.5;
uniform float noise_scale = 0.5; // Added uniform to control noise size

varying vec3 world_coords;

vec3 fractal_contour_lines(float thickness, float interval, vec3 world_pos, vec3 camera_position, vec3 base_ddx, vec3 base_ddy) {
	float depth = max(log(length(world_pos - camera_position) / interval) * (1.0 / log2(2.0)) - 1.0, 1.0);

	float interval_a = interval * exp2(max(floor(depth) - 1.0, 1.0)) * 0.5;
	float interval_b = interval * exp2(max(floor(depth), 1.0)) * 0.5;
	float interval_c = interval * exp2(max(floor(depth + 0.5) - 1.0, 1.0)) * 0.5;

	vec3 y = world_pos;
	vec3 y_fwidth = abs(base_ddx) + abs(base_ddy);

	float mi = max(0.0, thickness - 1.0);
	float ma = max(1.0, thickness);
	float mx = max(0.0, 1.0 - thickness);

	// Line A
	float inv_interval_a = 1.0 / interval_a;
	vec3 f_a = abs(fract((y + interval_a * 0.5) * inv_interval_a) - 0.5);
	vec3 df_a = y_fwidth * inv_interval_a;
	vec3 line_a = clamp((f_a - df_a * mi) / (df_a * (ma - mi)), mx, 1.0);

	// Line B
	float inv_interval_b = 1.0 / interval_b;
	vec3 f_b = abs(fract((y + interval_b * 0.5) * inv_interval_b) - 0.5);
	vec3 df_b = y_fwidth * inv_interval_b;
	vec3 line_b = clamp((f_b - df_b * mi) / (df_b * (ma - mi)), mx, 1.0);

	// Line C
	float inv_interval_c = 1.0 / interval_c;
	vec3 f_c = abs(fract((y + interval_c * 0.5) * inv_interval_c) - 0.5);
	vec3 df_c = y_fwidth * inv_interval_c;
	vec3 line_c = clamp((f_c - df_c * mi) / (df_c * (ma - mi)), mx, 1.0);

	// Blend out
	float p = fract(depth - 0.5);
	vec3 line = mix(mix(line_a, line_b, fract(depth)), line_c, (4.0 * p * (1.0 - p)));
	return 1.0 - vec3(line);
}

void vertex() {
	// Calculate the world coordinates in the vertex shader.
	// This is the correct way to get the world position of each vertex.
	world_coords = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// The world position is now correctly interpolated from the vertex shader.
	vec3 ddx = dFdx(world_coords);
	vec3 ddy = dFdy(world_coords);
	vec3 world_normal = normalize(cross(ddy, ddx));
	vec3 line = fractal_contour_lines(line_thickness, line_interval, world_coords, CAMERA_POSITION_WORLD, ddx, ddy);
	vec3 color = vec3(.58, .56, .61);
	
	// Sample the noise texture using the X and Z coordinates of the world position.
	vec2 noise_uv = world_coords.xz * noise_scale;
	float noise_value = texture(noise_texture, noise_uv).x;
	
	vec3 final_color = color * (1.0 + (noise_value * intensity));
	
	// Y only
	ALBEDO = mix(final_color, line_color, clamp(line.y, 0.0, 1.0));
	// XYZ
	//ALBEDO = mix(vec3(0.1), line_color, clamp(line.x + line.y + line.z, 0., 1.));
}