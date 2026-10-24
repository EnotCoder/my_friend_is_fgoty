# res://addons/virtual_joystick_DX/vjdx_haptics.gd
class_name VJDXHaptics
extends RefCounted

var enabled: bool = true
var is_mobile: bool = false

func _init() -> void:
	is_mobile = OS.has_feature("mobile")

func vibrate(duration_ms: int, amplitude: float) -> void:
	if not enabled or not is_mobile or Engine.is_editor_hint():
		return
	Input.vibrate_handheld(duration_ms, amplitude)