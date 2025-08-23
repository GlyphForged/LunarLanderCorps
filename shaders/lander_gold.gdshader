shader_type spatial;

void fragment() {
	float r = 212. / 255.;
	float g = 175. / 255.;
	float b = 55. / 255.;
	vec3 gold = vec3(r, g, b);
	ALBEDO = gold;
	METALLIC = 0.5;
	ROUGHNESS = 0.3;
}
