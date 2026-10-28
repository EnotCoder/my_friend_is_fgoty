shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture
    : hint_screen_texture, repeat_disable, filter_linear_mipmap;

// Сила размытия: 0 — без размытия.
uniform float blur_amount : hint_range(0.0, 6.0, 0.1) = 3.0;

void fragment() {
    vec3 blurred = textureLod(
        screen_texture,
        SCREEN_UV,
        blur_amount
    ).rgb;

    COLOR = vec4(blurred, 1.0);
}