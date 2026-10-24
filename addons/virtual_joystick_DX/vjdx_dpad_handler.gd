# res://addons/virtual_joystick_DX/vjdx_dpad_handler.gd
class_name VJDXDpadHandler
extends RefCounted

signal direction_changed()

var radius: float = 80.0
var deadzone: float = 0.15
var use_textures: bool = true
var preset: int = 0

var tex_idle: Texture2D
var tex_up: Texture2D
var tex_down: Texture2D
var tex_left: Texture2D
var tex_right: Texture2D
var tex_up_right: Texture2D
var tex_up_left: Texture2D
var tex_down_right: Texture2D
var tex_down_left: Texture2D

var active_direction: Vector2 = Vector2.ZERO

var _preset_cache: Array[Texture2D] = []
var _preset_cache_dirty: bool = true

const _PRESET_FILES: Array[String] = [
	"idle", "up", "down", "left", "right", "up_right", "up_left", "down_right", "down_left"
]

func calculate_value(offset: Vector2, dist: float) -> Vector2:
	var dz_px: float = deadzone * radius
	if dist < 0.001 or dist <= dz_px:
		_update_active_dir(Vector2.ZERO)
		return Vector2.ZERO

	var nx: float = offset.x / dist
	var ny: float = offset.y / dist

	const DIAG_T: float = 0.3827

	var dir: Vector2 = Vector2.ZERO
	if nx > DIAG_T: dir.x = 1.0
	elif nx < -DIAG_T: dir.x = -1.0
	if ny > DIAG_T: dir.y = 1.0
	elif ny < -DIAG_T: dir.y = -1.0

	if dir == Vector2.ZERO:
		dir.x = signf(nx)
		dir.y = signf(ny)

	_update_active_dir(dir)
	return dir

func _update_active_dir(new_dir: Vector2) -> void:
	if new_dir != active_direction:
		active_direction = new_dir
		direction_changed.emit()

func mark_cache_dirty() -> void:
	_preset_cache_dirty = true

func load_preset_cache() -> void:
	_preset_cache.clear()
	var folder: String = "res://addons/virtual_joystick_DX/Dpad textures/preset 1/" if preset == 0 else "res://addons/virtual_joystick_DX/Dpad textures/preset 2/"
	for f in _PRESET_FILES:
		var path: String = folder + f + ".svg"
		if ResourceLoader.exists(path):
			_preset_cache.append(load(path) as Texture2D)
		else:
			_preset_cache.append(null)
	_preset_cache_dirty = false

func get_octant_index() -> int:
	var pos_x: float = active_direction.x
	var pos_y: float = active_direction.y
	if pos_y < 0 and pos_x > 0: return 5
	if pos_y < 0 and pos_x < 0: return 6
	if pos_y > 0 and pos_x > 0: return 7
	if pos_y > 0 and pos_x < 0: return 8
	if pos_y < 0: return 1
	if pos_y > 0: return 2
	if pos_x < 0: return 3
	if pos_x > 0: return 4
	return 0

func get_custom_texture(idx: int) -> Texture2D:
	match idx:
		0: return tex_idle
		1: return tex_up
		2: return tex_down
		3: return tex_left
		4: return tex_right
		5: return tex_up_right
		6: return tex_up_left
		7: return tex_down_right
		8: return tex_down_left
	return null

func get_active_texture() -> Texture2D:
	if not use_textures:
		return null

	var idx: int = get_octant_index()
	var custom: Texture2D = get_custom_texture(idx)
	if custom:
		return custom

	if _preset_cache_dirty:
		load_preset_cache()
	if idx < _preset_cache.size():
		return _preset_cache[idx]
	return null