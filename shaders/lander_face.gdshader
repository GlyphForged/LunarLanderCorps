shader_type spatial;

void fragment() {
	float brightness = 0.2;
	ALBEDO = vec3(brightness);
	METALLIC = 0.2;
	ROUGHNESS = 0.8;
}
