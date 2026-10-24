shader_type spatial;

render_mode unshaded, depth_test_disabled, depth_draw_never;

uniform vec4 xray_color : source_color = vec4(0.05, 0.3, 1.0, 1.0);
uniform float opacity : hint_range(0.0, 1.0) = 0.7;
uniform float depth_bias : hint_range(0.001, 0.2) = 0.03;

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).r;

	// Восстанавливаем позицию видимой поверхности в пространстве камеры.
	#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
		vec3 ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
	#else
		vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	#endif

	vec4 scene_position = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	scene_position.xyz /= scene_position.w;

	float scene_depth = -scene_position.z;
	float object_depth = -VERTEX.z;

	// Показываем синий цвет только там, где объект за препятствием.
	float hidden = step(scene_depth + depth_bias, object_depth);

	ALBEDO = xray_color.rgb;
	ALPHA = hidden * opacity * xray_color.a;
}