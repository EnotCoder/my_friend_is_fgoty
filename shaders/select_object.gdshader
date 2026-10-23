shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never;

uniform vec3 highlight_color : source_color = vec3(0.3, 0.85, 1.0);
uniform float opacity : hint_range(0.0, 1.0) = 0.0;

uniform float stripe_spacing : hint_range(4.0, 40.0) = 12.0;
uniform float stripe_width : hint_range(0.05, 0.9) = 0.3;
uniform float stripe_speed : hint_range(0.0, 100.0) = 20.0;

void fragment() {
	// Диагональные полосы в экранных координатах.
	float coordinate = (
		FRAGCOORD.x + FRAGCOORD.y + TIME * stripe_speed
	) / stripe_spacing;

	float pattern = fract(coordinate);

	// Сглаживаем края полос.
	float edge = min(fwidth(coordinate), 0.1);
	float stripe =
		smoothstep(0.0, edge, pattern)
		* (1.0 - smoothstep(
			stripe_width - edge,
			stripe_width,
			pattern
		));

	ALBEDO = highlight_color;

	// Слабая заливка между полосами и более яркие полосы.
	ALPHA = opacity * mix(0.08, 0.65, stripe);
}