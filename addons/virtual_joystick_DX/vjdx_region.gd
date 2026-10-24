# res://addons/virtual_joystick_DX/vjdx_region.gd
class_name VJDXRegion
extends RefCounted

var enabled: bool = true
var x: float = 0.0
var y: float = 0.0
var w: float = 576.0
var h: float = 648.0

var debug_show: bool = true
var debug_color: Color = Color(0x3de976bd)

func get_rect(viewport_size: Vector2) -> Rect2:
	return Rect2(x, y, clampf(w, 0.0, viewport_size.x - x), clampf(h, 0.0, viewport_size.y - y))

func contains(screen_pos: Vector2, viewport_size: Vector2, control_rect: Rect2) -> bool:
	if not enabled:
		return control_rect.has_point(screen_pos)
	return get_rect(viewport_size).has_point(screen_pos)

func clamp_position(screen_pos: Vector2, viewport_size: Vector2) -> Vector2:
	if not enabled:
		return screen_pos
	var r := get_rect(viewport_size)
	return Vector2(
		clampf(screen_pos.x, r.position.x, r.end.x),
		clampf(screen_pos.y, r.position.y, r.end.y)
	)