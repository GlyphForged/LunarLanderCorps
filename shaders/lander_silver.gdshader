shader_type spatial;

void fragment() {
	float brightness = 0.9;
	ALBEDO = vec3(brightness);
	METALLIC = 0.8;
	ROUGHNESS = 0.2;
}
