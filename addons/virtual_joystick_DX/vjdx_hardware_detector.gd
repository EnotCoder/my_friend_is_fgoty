# res://addons/virtual_joystick_DX/vjdx_hardware_detector.gd
class_name VJDXHardwareDetector
extends RefCounted

signal visibility_changed(show: bool)

var auto_hide_on_physical_input: bool = true
var auto_show_on_touch: bool = true
var is_hidden: bool = false

func setup() -> void:
	if Engine.is_editor_hint():
		return
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	_check_hardware_state()

func _check_hardware_state() -> void:
	if auto_hide_on_physical_input and Input.get_connected_joypads().size() > 0:
		_apply_visibility(false)

func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	if auto_hide_on_physical_input:
		_apply_visibility(Input.get_connected_joypads().size() == 0)

func process_event(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return

	if auto_hide_on_physical_input and event is InputEventKey and event.pressed:
		_apply_visibility(false)
		return

	if auto_show_on_touch and not is_hidden and auto_hide_on_physical_input:
		if event is InputEventJoypadButton and event.pressed:
			_apply_visibility(false)
			return
		if event is InputEventJoypadMotion and absf(event.axis_value) > 0.2:
			_apply_visibility(false)
			return

	if is_hidden and auto_show_on_touch:
		if event is InputEventScreenTouch or event is InputEventScreenDrag:
			_apply_visibility(true)

func _apply_visibility(show: bool) -> void:
	is_hidden = not show
	visibility_changed.emit(show)