shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec3 background_color : source_color = vec3(0.002, 0.008, 0.003);
uniform vec3 code_color : source_color = vec3(0.05, 0.95, 0.2);
uniform vec3 head_color : source_color = vec3(0.7, 1.0, 0.8);

uniform float columns : hint_range(10.0, 100.0) = 48.0;
uniform float rows : hint_range(10.0, 80.0) = 30.0;

// Скорость в строках за секунду.
uniform float fall_speed : hint_range(1.0, 100.0) = 35.0;

// Длина светящегося хвоста в строках.
uniform float trail_length : hint_range(3.0, 40.0) = 14.0;

// Частота изменения символов.
uniform float symbol_change_speed : hint_range(0.0, 30.0) = 10.0;

uniform float brightness : hint_range(0.2, 3.0) = 1.2;
uniform float scanline_strength : hint_range(0.0, 0.3) = 0.08;
uniform bool flip_y = false;


float random_value(vec2 p) {
	return fract(
		sin(dot(p, vec2(127.1, 311.7))) * 43758.5453
	);
}


float rectangle(vec2 p, vec2 minimum, vec2 maximum) {
	vec2 inside = step(minimum, p) * (1.0 - step(maximum, p));
	return inside.x * inside.y;
}


// Процедурный псевдосимвол на сетке 4 × 6.
float glyph(vec2 cell_uv, vec2 seed) {
	float bounds = rectangle(
		cell_uv,
		vec2(0.15, 0.1),
		vec2(0.85, 0.9)
	);

	vec2 glyph_uv = (
		cell_uv - vec2(0.15, 0.1)
	) / vec2(0.7, 0.8);

	vec2 pixel = floor(glyph_uv * vec2(4.0, 6.0));
	vec2 pixel_uv = fract(glyph_uv * vec2(4.0, 6.0));

	float ink = step(
		0.47,
		random_value(seed + pixel * vec2(13.7, 7.9))
	);

	// Небольшие промежутки между пикселями символа.
	float pixel_shape = rectangle(
		pixel_uv,
		vec2(0.04),
		vec2(0.96)
	);

	return bounds * ink * pixel_shape;
}


void fragment() {
	vec2 uv = UV;

	if (flip_y) {
		uv.y = 1.0 - uv.y;
	}

	vec2 grid = uv * vec2(columns, rows);
	vec2 cell = floor(grid);
	vec2 cell_uv = fract(grid);

	float column_id = cell.x;

	// Разная скорость для каждого столбца.
	float speed_multiplier = mix(
		0.65,
		1.65,
		random_value(vec2(column_id, 1.0))
	);

	// Разная длина хвоста.
	float length_multiplier = mix(
		0.6,
		1.4,
		random_value(vec2(column_id, 2.0))
	);

	float tail = trail_length * length_multiplier;

	// Между хвостом одного потока и следующим есть промежуток.
	float cycle_length = rows + tail + 8.0;

	float offset = random_value(
		vec2(column_id, 3.0)
	) * cycle_length;

	// Координата головы потока. Рост Y — движение вниз.
	float head_position = mod(
		TIME * fall_speed * speed_multiplier + offset,
		cycle_length
	);

	// Расстояние от символа до головы вдоль хвоста.
	float distance_to_head = mod(
		head_position - cell.y,
		cycle_length
	);

	float trail = 1.0 - smoothstep(
		0.0,
		tail,
		distance_to_head
	);

	// Самая яркая часть потока.
	float head = 1.0 - smoothstep(
		0.0,
		1.8,
		distance_to_head
	);

	// Символы периодически меняют рисунок.
	float symbol_frame = floor(
		TIME * symbol_change_speed
	);

	vec2 seed = vec2(
		column_id * 19.3 + symbol_frame,
		cell.y * 7.1
	);

	float character = glyph(cell_uv, seed);

	// Разная яркость отдельных символов.
	float variation = mix(
		0.45,
		1.0,
		random_value(cell + vec2(symbol_frame, 0.0))
	);

	vec3 ink_color = mix(code_color, head_color, head);
	float intensity = trail * variation + head * 0.7;

	vec3 color = background_color;
	color += ink_color * character * intensity;

	// Слабое свечение под яркой головой потока.
	float horizontal_glow = 1.0 - smoothstep(
		0.0,
		0.5,
		abs(cell_uv.x - 0.5)
	);

	color += code_color * head * horizontal_glow * 0.06;

	// Полосы экрана.
	float scanlines = 0.5 + 0.5 * sin(uv.y * 1000.0);
	color *= 1.0 - scanlines * scanline_strength;

	ALBEDO = color * brightness;
}