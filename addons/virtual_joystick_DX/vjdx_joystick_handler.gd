# res://addons/virtual_joystick_DX/vjdx_joystick_handler.gd
class_name VJDXJoystickHandler
extends RefCounted

const MODE_STATIC: int = 0
const MODE_DYNAMIC: int = 1
const MODE_FOLLOWING: int = 2

var radius: float = 80.0
var thumb_radius: float = 28.0
var deadzone: float = 0.15
var mode: int = MODE_STATIC
var clampzone_ratio: float = 1.5

func get_max_deadzone() -> float:
	if radius > 0.0:
		return minf(thumb_radius / radius, 0.999)
	return 0.9

func is_dynamic() -> bool:
	return mode == MODE_DYNAMIC

func is_following() -> bool:
	return mode == MODE_FOLLOWING

func is_movable() -> bool:
	return mode == MODE_DYNAMIC or mode == MODE_FOLLOWING

func should_release_by_clampzone(dist: float) -> bool:
	return dist > radius * clampzone_ratio

func compute_reposition_target(global_pos: Vector2, center: Vector2, offset: Vector2, dist: float) -> Vector2:
	var dir: Vector2 = offset / dist
	return (global_pos + center) + offset - dir * radius

func calculate_value(offset: Vector2, dist: float) -> Vector2:
	var dz_px: float = deadzone * radius
	if dist < 0.001 or dist <= dz_px:
		return Vector2.ZERO

	var direction: Vector2 = offset / dist
	if is_zero_approx(deadzone):
		return direction

	var t: float = clampf((dist - dz_px) / (radius - dz_px), 0.0, 1.0)
	return direction * t