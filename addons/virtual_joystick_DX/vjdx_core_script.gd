# res://addons/virtual_joystick_DX/vjdx_core_script.gd
@tool
extends Control
class_name VirtualJoystickDX

# Enums & Signals
enum ControllerStyle {JOYSTICK, DPAD}
enum JoystickMode {STATIC, DYNAMIC, FOLLOWING}
enum DpadPreset {PRESET_1, PRESET_2}

signal joystick_moved(direction: Vector2)
signal joystick_released()
signal hardware_visibility_changed(is_visible: bool)
signal action_fired(action_name: StringName, strength: float)

var region := VJDXRegion.new()
var haptics := VJDXHaptics.new()
var hw_detector := VJDXHardwareDetector.new()
var joystick := VJDXJoystickHandler.new()
var dpad := VJDXDpadHandler.new()

# Helpers del Inspector
func _refresh_inspector() -> void:
	notify_property_list_changed()
	queue_redraw()

func _refresh_editor_state() -> void:
	_refresh_inspector()
	update_configuration_warnings()

# Propiedades del Inspector expuestas
@export_category("Controller Settings")
@export var controller_style: ControllerStyle = ControllerStyle.JOYSTICK:
	set(v):
		controller_style = v
		_refresh_editor_state()

@export_range(20.0, 400.0, 1.0, "suffix:px") var joystick_radius: float = 80.0:
	set(v):
		joystick_radius = maxf(v, 10.0)
		if joystick:
			joystick.radius = joystick_radius
			custom_minimum_size = Vector2(joystick_radius * 2.0, joystick_radius * 2.0)
		_refresh_editor_state()

@export_range(5.0, 200.0, 1.0, "suffix:px") var thumb_radius: float = 28.0:
	set(v):
		thumb_radius = maxf(v, 5.0)
		if joystick: joystick.thumb_radius = thumb_radius
		_refresh_inspector()

@export_range(20.0, 400.0, 1.0, "suffix:px") var dpad_radius: float = 80.0:
	set(v):
		dpad_radius = maxf(v, 10.0)
		if dpad: dpad.radius = dpad_radius
		_refresh_editor_state()

@export var deadzone: float = 0.15:
	set(v):
		deadzone = clampf(v, 0.0, _max_deadzone())
		if joystick: joystick.deadzone = deadzone
		if dpad: dpad.deadzone = deadzone
		queue_redraw()

@export var debug_deadzone: bool = true:
	set(v):
		debug_deadzone = v
		_refresh_inspector()

@export var deadzone_color: Color = Color(0xe93d3dff):
	set(v):
		deadzone_color = v
		queue_redraw()

@export_group("Haptic Feedback")
@export var haptic_enabled: bool = true:
	set(v):
		haptic_enabled = v
		if haptics: haptics.enabled = haptic_enabled
		_refresh_inspector()

@export var haptic_joystick_on_press: bool = true:
	set(v):
		haptic_joystick_on_press = v
		_refresh_editor_state()
@export_range(10, 500, 1, "suffix:ms") var haptic_joystick_press_duration: int = 25
@export_range(0.0, 1.0, 0.05) var haptic_joystick_press_amplitude: float = 0.4

@export var haptic_joystick_on_release: bool = true:
	set(v):
		haptic_joystick_on_release = v
		_refresh_editor_state()
@export_range(10, 500, 1, "suffix:ms") var haptic_joystick_release_duration: int = 20
@export_range(0.0, 1.0, 0.05) var haptic_joystick_release_amplitude: float = 0.25

@export var haptic_dpad_on_press: bool = true:
	set(v):
		haptic_dpad_on_press = v
		_refresh_editor_state()
@export_range(10, 500, 1, "suffix:ms") var haptic_dpad_press_duration: int = 25
@export_range(0.0, 1.0, 0.05) var haptic_dpad_press_amplitude: float = 0.4

@export var haptic_dpad_on_release: bool = true:
	set(v):
		haptic_dpad_on_release = v
		_refresh_editor_state()
@export_range(10, 500, 1, "suffix:ms") var haptic_dpad_release_duration: int = 20
@export_range(0.0, 1.0, 0.05) var haptic_dpad_release_amplitude: float = 0.25

@export var haptic_dpad_on_change: bool = true
@export_range(10, 200, 1, "suffix:ms") var haptic_dpad_change_duration: int = 18
@export_range(0.0, 1.0, 0.05) var haptic_dpad_change_amplitude: float = 0.55

@export_category("Dynamic Visibility")
@export_group("Auto-hide by Hardware")
@export var auto_hide_on_physical_input: bool = true:
	set(v):
		auto_hide_on_physical_input = v
		if hw_detector: hw_detector.auto_hide_on_physical_input = v
@export var auto_show_on_touch: bool = true:
	set(v):
		auto_show_on_touch = v
		if hw_detector: hw_detector.auto_show_on_touch = v

@export_category("Joystick Mode")
@export var joystick_mode: JoystickMode = JoystickMode.STATIC:
	set(v):
		joystick_mode = v
		if joystick: joystick.mode = joystick_mode
		notify_property_list_changed()
		update_configuration_warnings()

@export_range(1.0, 3.0, 0.05) var clampzone_ratio: float = 1.5:
	set(v):
		clampzone_ratio = v
		if joystick: joystick.clampzone_ratio = clampzone_ratio
		queue_redraw()

@export var debug_clampzone: bool = true:
	set(v):
		debug_clampzone = v
		_refresh_inspector()
@export var clampzone_color: Color = Color(0xe9e83dbd):
	set(v):
		clampzone_color = v
		queue_redraw()

@export_category("Input Mapping")
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin, loose_mode") var action_left: StringName = "ui_left"
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin, loose_mode") var action_right: StringName = "ui_right"
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin, loose_mode") var action_up: StringName = "ui_up"
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin, loose_mode") var action_down: StringName = "ui_down"

@export_subgroup("Action Mapping")
@export var use_directional_mapping: bool = true:
	set(v):
		use_directional_mapping = v
		if not v: _reset_actions()
		_refresh_inspector()
@export var action_bindings: Array[VJDXActionBinding] = []

@export_category("Active Region")
@export var use_active_region: bool = true:
	set(v):
		use_active_region = v
		if region: region.enabled = v
		_refresh_inspector()
@export var debug_show_region: bool = true:
	set(v):
		debug_show_region = v
		if region: region.debug_show = v
		_refresh_inspector()
@export var debug_region_color: Color = Color(0x3de976bd):
	set(v):
		debug_region_color = v
		if region: region.debug_color = v
		queue_redraw()

@export var region_x: float = 0.0:
	set(v):
		var vp := _get_viewport_size()
		region_x = clampf(v, 0.0, vp.x)
		region_w = clampf(region_w, 0.0, vp.x - region_x)
		if region: region.x = region_x
		queue_redraw()

@export var region_y: float = 0.0:
	set(v):
		var vp := _get_viewport_size()
		region_y = clampf(v, 0.0, vp.y)
		region_h = clampf(region_h, 0.0, vp.y - region_y)
		if region: region.y = region_y
		queue_redraw()

@export var region_w: float = 576.0:
	set(v):
		var vp := _get_viewport_size()
		region_w = clampf(v, 0.0, vp.x - region_x)
		if region: region.w = region_w
		queue_redraw()

@export var region_h: float = 648.0:
	set(v):
		var vp := _get_viewport_size()
		region_h = clampf(v, 0.0, vp.y - region_y)
		if region: region.h = region_h
		queue_redraw()

var active_region: Rect2:
	get: return region.get_rect(get_viewport_rect().size)

@export_category("Textures")
@export_group("Colors - Joystick")
@export var color_js_base: Color = Color(0x1f1f1f8c)
@export var color_js_border: Color = Color(0xe0e0e06b)
@export var color_js_thumb: Color = Color(0xe6e6e6d1)
@export var color_js_thumb_active: Color = Color(0xe97d3dff)

@export_group("Colors - D-Pad")
@export var color_dp_bg: Color = Color(0x14141459)
@export var color_dp_border: Color = Color(0xe0e0e06b)
@export var color_dp_normal: Color = Color(0x595959b8)
@export var color_dp_active: Color = Color(0xe97d3dff)
@export var color_dp_arrow: Color = Color(0xffffffe0)

@export_group("Textures - Joystick")
@export var tex_joystick_base: Texture2D:
	set(v): tex_joystick_base = v; queue_redraw()
@export var tex_joystick_thumb: Texture2D:
	set(v): tex_joystick_thumb = v; queue_redraw()
@export var tex_joystick_thumb_pressed: Texture2D:
	set(v): tex_joystick_thumb_pressed = v; queue_redraw()

@export_group("Textures - D-Pad")
@export var dpad_use_textures: bool = true:
	set(v):
		dpad_use_textures = v
		if dpad: dpad.use_textures = v
		_refresh_inspector()
@export var dpad_preset: DpadPreset = DpadPreset.PRESET_1:
	set(v):
		dpad_preset = v
		if dpad:
			dpad.preset = int(v)
			dpad.mark_cache_dirty()
		queue_redraw()
@export var tex_dpad_idle: Texture2D:
	set(v): tex_dpad_idle = v; if dpad: dpad.tex_idle = v; queue_redraw()

@export_subgroup("Cardinals")
@export var tex_dpad_up: Texture2D:
	set(v): tex_dpad_up = v; if dpad: dpad.tex_up = v; queue_redraw()
@export var tex_dpad_down: Texture2D:
	set(v): tex_dpad_down = v; if dpad: dpad.tex_down = v; queue_redraw()
@export var tex_dpad_left: Texture2D:
	set(v): tex_dpad_left = v; if dpad: dpad.tex_left = v; queue_redraw()
@export var tex_dpad_right: Texture2D:
	set(v): tex_dpad_right = v; if dpad: dpad.tex_right = v; queue_redraw()

@export_subgroup("Diagonals")
@export var tex_dpad_up_right: Texture2D:
	set(v): tex_dpad_up_right = v; if dpad: dpad.tex_up_right = v; queue_redraw()
@export var tex_dpad_up_left: Texture2D:
	set(v): tex_dpad_up_left = v; if dpad: dpad.tex_up_left = v; queue_redraw()
@export var tex_dpad_down_right: Texture2D:
	set(v): tex_dpad_down_right = v; if dpad: dpad.tex_down_right = v; queue_redraw()
@export var tex_dpad_down_left: Texture2D:
	set(v): tex_dpad_down_left = v; if dpad: dpad.tex_down_left = v; queue_redraw()

# Estado Interno
var value: Vector2 = Vector2.ZERO
var is_pressed: bool = false
var _touch_index: int = -1
var _active_action_names: Dictionary = {}
var _touch_start_msec: int = 0
var _touch_exceeded_deadzone: bool = false
var _last_value_length: float = 0.0
var _center: Vector2 = Vector2.ZERO
var _knob_pos: Vector2 = Vector2.ZERO
var _origin_pos: Vector2 = Vector2.ZERO

# Inicialización y Sincronización
func _ready() -> void:
	_origin_pos = position
	_center = size / 2.0
	pivot_offset = _center
	_knob_pos = _center
	mouse_filter = MOUSE_FILTER_IGNORE

	dpad.direction_changed.connect(_on_dpad_direction_changed)
	hw_detector.visibility_changed.connect(_on_hw_visibility_changed)

	_sync_properties_to_handlers()

	if not Engine.is_editor_hint():
		hw_detector.setup()
		set_process_input(true)

func _sync_properties_to_handlers() -> void:
	joystick.radius = joystick_radius
	joystick.thumb_radius = thumb_radius
	joystick.deadzone = deadzone
	joystick.mode = joystick_mode
	joystick.clampzone_ratio = clampzone_ratio

	dpad.radius = dpad_radius
	dpad.deadzone = deadzone
	dpad.use_textures = dpad_use_textures
	dpad.preset = int(dpad_preset)
	dpad.tex_idle = tex_dpad_idle
	dpad.tex_up = tex_dpad_up
	dpad.tex_down = tex_dpad_down
	dpad.tex_left = tex_dpad_left
	dpad.tex_right = tex_dpad_right
	dpad.tex_up_right = tex_dpad_up_right
	dpad.tex_up_left = tex_dpad_up_left
	dpad.tex_down_right = tex_dpad_down_right
	dpad.tex_down_left = tex_dpad_down_left
	dpad.mark_cache_dirty()

	region.enabled = use_active_region
	region.x = region_x
	region.y = region_y
	region.w = region_w
	region.h = region_h
	region.debug_show = debug_show_region
	region.debug_color = debug_region_color

	hw_detector.auto_hide_on_physical_input = auto_hide_on_physical_input
	hw_detector.auto_show_on_touch = auto_show_on_touch

	haptics.enabled = haptic_enabled

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_RESIZED:
			_center = size / 2.0
			pivot_offset = _center
			_knob_pos = _center if not is_pressed else _knob_pos
			queue_redraw()
		NOTIFICATION_ENTER_TREE:
			if not Engine.is_editor_hint():
				_origin_pos = position

func _active_radius() -> float:
	return joystick_radius if controller_style == ControllerStyle.JOYSTICK else dpad_radius

func _max_deadzone() -> float:
	if joystick:
		return joystick.get_max_deadzone()
	return 0.9

func _get_viewport_size() -> Vector2:
	var w: float = ProjectSettings.get_setting("display/window/size/viewport_width", 1920)
	var h: float = ProjectSettings.get_setting("display/window/size/viewport_height", 1080)
	return Vector2(w, h)

# Manejo de Entradas Físicas y Virtuales
func _on_hw_visibility_changed(show: bool) -> void:
	visible = show
	hardware_visibility_changed.emit(show)
	if not show:
		_do_release()

func _input(event: InputEvent) -> void:
	if hw_detector.auto_hide_on_physical_input or hw_detector.auto_show_on_touch:
		hw_detector.process_event(event)

	if hw_detector.is_hidden or not visible:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			_begin_touch(event.index, event.position)
		elif event.index == _touch_index:
			_do_release()
	elif event is InputEventScreenDrag:
		if event.index == _touch_index:
			_update_stick(event.position)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_begin_touch(0, event.position)
			elif _touch_index == 0:
				_do_release()
	elif event is InputEventMouseMotion:
		if _touch_index == 0 and (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
			_update_stick(event.position)

func _to_local(screen_pos: Vector2) -> Vector2:
	return (screen_pos - global_position) / scale

func _begin_touch(index: int, screen_pos: Vector2) -> void:
	if _touch_index != -1:
		return

	var control_rect := get_global_rect()
	var vp_size := get_viewport_rect().size

	if controller_style == ControllerStyle.JOYSTICK and joystick.is_following():
		if not control_rect.has_point(screen_pos):
			return
	else:
		if not region.contains(screen_pos, vp_size, control_rect):
			return

	_touch_index = index
	is_pressed = true
	_touch_start_msec = Time.get_ticks_msec()
	_touch_exceeded_deadzone = false

	if controller_style == ControllerStyle.JOYSTICK:
		if haptic_joystick_on_press:
			haptics.vibrate(haptic_joystick_press_duration, haptic_joystick_press_amplitude)
		if joystick.is_dynamic():
			_reposition_base(screen_pos)
			_center = size / 2.0
			_knob_pos = _center
	else:
		if haptic_dpad_on_press:
			haptics.vibrate(haptic_dpad_press_duration, haptic_dpad_press_amplitude)

	_update_stick(screen_pos)

func _reposition_base(screen_pos: Vector2) -> void:
	var vp_size := get_viewport_rect().size
	var spawn: Vector2 = region.clamp_position(screen_pos, vp_size)
	var parent := get_parent()
	var new_pos: Vector2
	if parent is CanvasItem:
		new_pos = (parent as CanvasItem).get_global_transform().affine_inverse() * spawn
	else:
		new_pos = spawn
	position = new_pos - size / 2.0

func _update_stick(screen_pos: Vector2) -> void:
	var radius: float = _active_radius()
	var is_movable_js: bool = (controller_style == ControllerStyle.JOYSTICK and joystick.is_movable())
	var is_static_mode: bool = not is_movable_js
	var vp_size := get_viewport_rect().size

	if region.enabled and is_static_mode:
		if not region.contains(screen_pos, vp_size, get_global_rect()):
			_do_release()
			return

	var local_pos: Vector2 = _to_local(screen_pos)
	var offset: Vector2 = local_pos - _center
	var dist: float = offset.length()

	if is_movable_js:
		if joystick.should_release_by_clampzone(dist):
			_do_release()
			return

		if dist > radius:
			var target_center: Vector2 = joystick.compute_reposition_target(global_position, _center, offset, dist)
			target_center = region.clamp_position(target_center, vp_size)

			var parent := get_parent()
			var new_pos: Vector2
			if parent is CanvasItem:
				new_pos = (parent as CanvasItem).get_global_transform().affine_inverse() * target_center
			else:
				new_pos = target_center
			position = new_pos - size / 2.0

			local_pos = _to_local(screen_pos)
			offset = local_pos - _center
			dist = offset.length()

	_knob_pos = _center + offset.limit_length(radius)

	if controller_style == ControllerStyle.JOYSTICK:
		value = joystick.calculate_value(offset, dist)
	else:
		value = dpad.calculate_value(offset, dist)

	if use_directional_mapping:
		_trigger_actions()
	var dist_fraction: float = clampf(dist / radius, 0.0, 1.0) if radius > 0.0 else 0.0
	if dist_fraction > deadzone:
		_touch_exceeded_deadzone = true
	_last_value_length = value.length()
	_update_action_bindings(dist_fraction)
	joystick_moved.emit(value)
	queue_redraw()

func _do_release() -> void:
	if _touch_index == -1:
		return
	_touch_index = -1
	is_pressed = false
	value = Vector2.ZERO
	dpad.active_direction = Vector2.ZERO
	_knob_pos = _center

	if controller_style == ControllerStyle.JOYSTICK and joystick.is_movable():
		position = _origin_pos
		_center = size / 2.0
		_knob_pos = _center

	if use_directional_mapping: _reset_actions()
	_release_all_action_bindings()

	if controller_style == ControllerStyle.JOYSTICK:
		if haptic_joystick_on_release:
			haptics.vibrate(haptic_joystick_release_duration, haptic_joystick_release_amplitude)
	else:
		if haptic_dpad_on_release:
			haptics.vibrate(haptic_dpad_release_duration, haptic_dpad_release_amplitude)

	joystick_released.emit()
	queue_redraw()

func _on_dpad_direction_changed() -> void:
	if not is_pressed or controller_style != ControllerStyle.DPAD:
		return
	if haptic_dpad_on_change and dpad.active_direction != Vector2.ZERO:
		haptics.vibrate(haptic_dpad_change_duration, haptic_dpad_change_amplitude)

# Emulación de Acciones de Entrada de Godot
func _apply_axis(val: float, neg_action: StringName, pos_action: StringName) -> void:
	_ensure_action_registered(neg_action)
	_ensure_action_registered(pos_action)
	if val < 0.0:
		if Input.is_action_pressed(pos_action): Input.action_release(pos_action)
		Input.action_press(neg_action, absf(val))
	elif val > 0.0:
		if Input.is_action_pressed(neg_action): Input.action_release(neg_action)
		Input.action_press(pos_action, val)
	else:
		Input.action_release(neg_action)
		Input.action_release(pos_action)

func _trigger_actions() -> void:
	_apply_axis(value.x, action_left, action_right)
	_apply_axis(value.y, action_up, action_down)

func _reset_actions() -> void:
	_ensure_action_registered(action_left)
	_ensure_action_registered(action_right)
	_ensure_action_registered(action_up)
	_ensure_action_registered(action_down)
	Input.action_release(action_left)
	Input.action_release(action_right)
	Input.action_release(action_up)
	Input.action_release(action_down)

func _update_action_bindings(dist_fraction: float) -> void:
	for bnd in action_bindings:
		if bnd == null or bnd.action_name == &"" or not bnd.is_held_type():
			continue
		var was_active: bool = _active_action_names.has(bnd.action_name)
		var should_be_active: bool = bnd.should_hold_active(dist_fraction, deadzone)
		if should_be_active and not was_active:
			_ensure_action_registered(bnd.action_name)
			Input.action_press(bnd.action_name, 1.0)
			action_fired.emit(bnd.action_name, 1.0)
			_active_action_names[bnd.action_name] = true
		elif not should_be_active and was_active:
			Input.action_release(bnd.action_name)
			_active_action_names.erase(bnd.action_name)

func _release_all_action_bindings() -> void:
	for act_name in _active_action_names.keys():
		Input.action_release(act_name)
	_active_action_names.clear()

	var held_msec: int = Time.get_ticks_msec() - _touch_start_msec
	for bnd in action_bindings:
		if bnd == null or bnd.action_name == &"":
			continue
		if bnd.is_on_release():
			_fire_pulse(bnd.action_name, clampf(_last_value_length, 0.0, 1.0))
		elif bnd.is_tap_gesture():
			if held_msec <= int(bnd.tap_max_duration * 1000.0) and not _touch_exceeded_deadzone:
				_fire_pulse(bnd.action_name, 1.0)

func _fire_pulse(act_name: StringName, strength: float) -> void:
	_ensure_action_registered(act_name)
	Input.action_press(act_name, strength)
	action_fired.emit(act_name, strength)
	call_deferred("_release_pulse", act_name)

func _release_pulse(act_name: StringName) -> void:
	Input.action_release(act_name)

func _ensure_action_registered(act_name: StringName) -> void:
	if not InputMap.has_action(act_name):
		InputMap.add_action(act_name)

# Renderizado Delegado al VJDXRenderer
func _draw() -> void:
	var vp_size := get_viewport_rect().size
	if Engine.is_editor_hint() and use_active_region and debug_show_region:
		VJDXRenderer.draw_debug_region(self, region.get_rect(vp_size), debug_region_color)

	match controller_style:
		ControllerStyle.JOYSTICK:
			VJDXRenderer.draw_joystick(
				self,
				_center,
				joystick_radius,
				_knob_pos,
				thumb_radius,
				is_pressed,
				tex_joystick_base,
				tex_joystick_thumb,
				tex_joystick_thumb_pressed,
				color_js_base,
				color_js_border,
				color_js_thumb,
				color_js_thumb_active
			)
			if Engine.is_editor_hint() and joystick.is_movable() and debug_clampzone:
				VJDXRenderer.draw_debug_clampzone(self, _center, joystick_radius * clampzone_ratio, clampzone_color)

		ControllerStyle.DPAD:
			VJDXRenderer.draw_dpad(
				self,
				_center,
				dpad_radius,
				dpad.active_direction,
				dpad.get_active_texture(),
				color_dp_bg,
				color_dp_border,
				color_dp_normal,
				color_dp_active,
				color_dp_arrow
			)

	if Engine.is_editor_hint() and debug_deadzone:
		VJDXRenderer.draw_debug_deadzone(self, _center, deadzone * _active_radius(), deadzone_color)

# Validación dinámica del Inspector de Godot
func _apply_region_hint(property: Dictionary, max_val: float) -> void:
	if not use_active_region:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	else:
		property.hint = PROPERTY_HINT_RANGE
		property.hint_string = "0.0,%.0f,1.0,suffix:px" % max_val

func _validate_property(property: Dictionary) -> void:
	var is_joystick: bool = (controller_style == ControllerStyle.JOYSTICK)
	var is_movable: bool = joystick.is_movable()
	var vp: Vector2 = _get_viewport_size()
	match property.name:
		# Nuevo: pivot_offset se gestiona en codigo, se oculta para evitar confusion
		"pivot_offset":
			property.usage = PROPERTY_USAGE_NO_EDITOR
		# Nuevo: accion direccional oculta si el mapeo direccional esta desactivado
		"action_left", "action_right", "action_up", "action_down":
			if not use_directional_mapping:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"Joystick Mode":
			if not is_joystick:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"joystick_mode",\
		"joystick_radius", "thumb_radius",\
		"Colors - Joystick",\
		"color_js_base", "color_js_border", "color_js_thumb", "color_js_thumb_active",\
		"Textures - Joystick",\
		"tex_joystick_base", "tex_joystick_thumb", "tex_joystick_thumb_pressed":
			if not is_joystick:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"clampzone_ratio", "debug_clampzone":
			if not (is_joystick and is_movable):
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"clampzone_color":
			if not (is_joystick and is_movable and debug_clampzone):
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"dpad_radius",\
		"Colors - D-Pad",\
		"color_dp_bg", "color_dp_border", "color_dp_normal", "color_dp_active", "color_dp_arrow",\
		"Textures - D-Pad", "dpad_use_textures":
			if is_joystick:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"dpad_preset":
			if is_joystick or not dpad_use_textures:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"tex_dpad_idle",\
		"Cardinals", "tex_dpad_up", "tex_dpad_down", "tex_dpad_left", "tex_dpad_right",\
		"Diagonals", "tex_dpad_up_right", "tex_dpad_up_left", "tex_dpad_down_right", "tex_dpad_down_left":
			if is_joystick or not dpad_use_textures:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"region_x":
			_apply_region_hint(property, vp.x)
		"region_y":
			_apply_region_hint(property, vp.y)
		"region_w":
			_apply_region_hint(property, maxf(0.0, vp.x - region_x))
		"region_h":
			_apply_region_hint(property, maxf(0.0, vp.y - region_y))
		"debug_show_region":
			if not use_active_region:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"debug_region_color":
			if not (use_active_region and debug_show_region):
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"deadzone_color":
			if not debug_deadzone:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"haptic_joystick_on_press", "haptic_joystick_on_release":
			if not haptic_enabled or not is_joystick:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"haptic_joystick_press_duration", "haptic_joystick_press_amplitude":
			if not haptic_enabled or not is_joystick or not haptic_joystick_on_press:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"haptic_joystick_release_duration", "haptic_joystick_release_amplitude":
			if not haptic_enabled or not is_joystick or not haptic_joystick_on_release:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"haptic_dpad_on_press", "haptic_dpad_on_release":
			if not haptic_enabled or is_joystick:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"haptic_dpad_press_duration", "haptic_dpad_press_amplitude":
			if not haptic_enabled or is_joystick or not haptic_dpad_on_press:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"haptic_dpad_release_duration", "haptic_dpad_release_amplitude":
			if not haptic_enabled or is_joystick or not haptic_dpad_on_release:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"haptic_dpad_on_change":
			if not haptic_enabled or is_joystick:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"haptic_dpad_change_duration", "haptic_dpad_change_amplitude":
			if not haptic_enabled or is_joystick or not haptic_dpad_on_change:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"deadzone":
			property.hint = PROPERTY_HINT_RANGE
			property.hint_string = "0.0,%.3f,0.001" % _max_deadzone()

# Funciones de Soporte Externo públicas
func release() -> void: _do_release()
func is_active() -> bool: return _touch_index != -1
func get_value() -> Vector2: return value

func _get_configuration_warnings() -> PackedStringArray:
	var w: PackedStringArray = []
	var r: float = _active_radius()
	if joystick.is_dynamic() and controller_style == ControllerStyle.DPAD:
		w.append("DYNAMIC only works in JOYSTICK mode. The D-Pad is always STATIC.")
	if joystick.is_following() and controller_style == ControllerStyle.DPAD:
		w.append("FOLLOWING only works in JOYSTICK mode. The D-Pad is always STATIC.")
	if size.x < r * 2.0 or size.y < r * 2.0:
		w.append("The node size is smaller than the control diameter (%dpx)." % int(r * 2.0))
	if use_active_region and active_region.size == Vector2.ZERO:
		w.append("The active region has a size of zero. Define a valid Rect2.")
	for bnd in action_bindings:
		if bnd != null and bnd.action_name == &"":
			w.append("There is an Action Binding without an assigned 'action_name'; it will do nothing.")
			break
	return w