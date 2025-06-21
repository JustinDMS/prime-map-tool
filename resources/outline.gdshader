shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0);
uniform float width : hint_range(0, 20) = 1.0;
uniform bool inside = false;

varying flat vec4 modulate;

// Color inside outline
void vertex() {
	modulate = COLOR;
}

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, sampler2D texture) {
	for (float i = -ceil(width); i <= ceil(width); i++) {
		float x = abs(i) > width ? width * sign(i) : i;
		float offset = floor(sqrt(pow(width + 0.5, 2) - x * x));

		for (float j = -ceil(offset); j <= ceil(offset); j++) {
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 xy = uv + texture_pixel_size * vec2(x, y);

			if ((xy != clamp(xy, vec2(0.0), vec2(1.0)) || texture(texture, xy).a <= 0.0) == inside) {
				return true;
			}
		}
	}

	return false;
}

void fragment() {
	vec2 uv = UV;
	COLOR = texture(TEXTURE, uv) * modulate;

	if ((COLOR.a > 0.0) == inside && hasContraryNeighbour(uv, TEXTURE_PIXEL_SIZE, TEXTURE)) {
		COLOR.rgb = inside ? mix(COLOR.rgb, color.rgb, color.a * modulate.a) : color.rgb * modulate.rgb;
		COLOR.a += (1.0 - COLOR.a) * color.a * modulate.a;
	}
}