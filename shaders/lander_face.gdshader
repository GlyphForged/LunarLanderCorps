shader_type spatial;

void fragment() {
	vec3 color = vec3(0.25, 0.04, 0.333);
	ALBEDO = vec3(color);
	EMISSION = vec3(color.r * 2.0, color.g * 2.0, color.b * 2.0);
	METALLIC = 0.2;
	ROUGHNESS = 0.8;
}
