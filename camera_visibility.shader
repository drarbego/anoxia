shader_type	canvas_item;

uniform float visibility_radius = 0.2;
uniform vec2 player_pos = vec2(0.5, 0.5);
const vec4 shadow = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	vec4 bg = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec2 uv = UV - player_pos;
	uv.x *= 1.7;
	float dist_to_center = length(uv);

	//COLOR = mix(shadow, bg, 1.0 - dist_to_center * 1.5);

	if (dist_to_center < visibility_radius) {
		COLOR = bg;
	} else {
		COLOR = mix(shadow, bg, 1.0 - dist_to_center * 1.5);
	}
}
