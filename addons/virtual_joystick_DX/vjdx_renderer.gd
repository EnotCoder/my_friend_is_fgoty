# res://addons/virtual_joystick_DX/vjdx_renderer.gd
class_name VJDXRenderer
extends RefCounted

static func rect_from_center(center: Vector2, rad: float) -> Rect2:
	return Rect2(center - Vector2(rad, rad), Vector2(rad, rad) * 2.0)

static func fill_color(base: Color, alpha_factor: float) -> Color:
	return Color(base.r, base.g, base.b, base.a * alpha_factor)

static func draw_ring(context: Control, center: Vector2, rad: float, col: Color, width: float) -> void:
	context.draw_arc(center, rad, 0.0, TAU, 64, col, width)

static func draw_joystick(
	context: Control,
	center: Vector2,
	radius: float,
	knob_pos: Vector2,
	thumb_radius: float,
	is_pressed: bool,
	tex_base: Texture2D,
	tex_thumb: Texture2D,
	tex_thumb_pressed: Texture2D,
	color_base: Color,
	color_border: Color,
	color_thumb: Color,
	color_thumb_active: Color
) -> void:
	if tex_base:
		context.draw_texture_rect(tex_base, rect_from_center(center, radius), false)
	else:
		context.draw_circle(center, radius, color_base)
		draw_ring(context, center, radius, color_border, 2.0)

	var active_thumb_tex: Texture2D = tex_thumb_pressed if (is_pressed and tex_thumb_pressed) else tex_thumb
	if active_thumb_tex:
		context.draw_texture_rect(active_thumb_tex, rect_from_center(knob_pos, thumb_radius), false)
	else:
		context.draw_circle(knob_pos + Vector2(1.5, 2.5), thumb_radius, Color(0xe0e0e06b))
		context.draw_circle(knob_pos, thumb_radius, color_thumb_active if is_pressed else color_thumb)

static func draw_dpad(
	context: Control,
	center: Vector2,
	radius: float,
	active_dir: Vector2,
	active_tex: Texture2D,
	color_bg: Color,
	color_border: Color,
	color_normal: Color,
	color_active: Color,
	color_arrow: Color
) -> void:
	var rect_full := rect_from_center(center, radius)
	if active_tex:
		context.draw_texture_rect(active_tex, rect_full, false)
		return

	context.draw_circle(center, radius, color_bg)
	var arm: float = radius * 0.54
	var hw: float = radius * 0.38
	var cross_color := fill_color(color_bg, 0.6)

	context.draw_rect(Rect2(center + Vector2(-hw, -radius * 0.94), Vector2(hw * 2.0, radius * 1.88)), cross_color, true)
	context.draw_rect(Rect2(center + Vector2(-radius * 0.94, -hw), Vector2(radius * 1.88, hw * 2.0)), cross_color, true)
	draw_ring(context, center, radius * 0.98, color_border, 1.5)

	var dirs: Array = [
		{"v": Vector2.UP, "off": Vector2(0.0, -arm)},
		{"v": Vector2.DOWN, "off": Vector2(0.0, arm)},
		{"v": Vector2.LEFT, "off": Vector2(-arm, 0.0)},
		{"v": Vector2.RIGHT, "off": Vector2(arm, 0.0)},
	]
	for d in dirs:
		var active: bool = d.v.dot(active_dir) > 0.0
		var bp: Vector2 = center + d.off
		var rect: Rect2 = Rect2(bp - Vector2(hw, hw), Vector2(hw, hw) * 2.0)
		context.draw_rect(rect, color_active if active else color_normal, true)
		context.draw_rect(rect, color_border, false, 1.4)
		draw_arrow(context, bp, d.v, hw * 0.52, color_arrow)

static func draw_arrow(context: Control, pos: Vector2, dir: Vector2, size: float, color: Color) -> void:
	var perp: Vector2 = Vector2(-dir.y, dir.x) * size * 0.62
	context.draw_colored_polygon(PackedVector2Array([
		pos + dir * size,
		pos - dir * size * 0.48 + perp,
		pos - dir * size * 0.48 - perp,
	]), color)

static func draw_debug_region(context: Control, active_region: Rect2, debug_color: Color) -> void:
	var xf: Transform2D = context.get_global_transform().affine_inverse()
	var tl: Vector2 = xf * active_region.position
	var br: Vector2 = xf * active_region.end
	var fill := fill_color(debug_color, 0.18)
	context.draw_rect(Rect2(tl, br - tl), fill, true)
	context.draw_rect(Rect2(tl, br - tl), debug_color, false, 2.0)

static func draw_debug_deadzone(context: Control, center: Vector2, radius: float, deadzone_color: Color) -> void:
	if radius < 0.5:
		return
	var fill := fill_color(deadzone_color, 0.45)
	context.draw_circle(center, radius, fill)
	draw_ring(context, center, radius, deadzone_color, 2.0)

static func draw_debug_clampzone(context: Control, center: Vector2, radius: float, clampzone_color: Color) -> void:
	var fill := fill_color(clampzone_color, 0.12)
	context.draw_circle(center, radius, fill)
	draw_ring(context, center, radius, clampzone_color, 2.0)