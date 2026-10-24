class_name VJDXActionBinding
extends Resource

enum TriggerMode { ON_TOUCH, CONTINUOUS, ON_THRESHOLD, ON_RELEASE, TAP_GESTURE }

@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin, loose_mode") var action_name: StringName = "fire"
@export var trigger_mode: TriggerMode = TriggerMode.CONTINUOUS:
	set(v):
		trigger_mode = v
		notify_property_list_changed()
@export_range(0.0, 1.0, 0.01) var threshold: float = 0.5
@export_range(0.05, 1.0, 0.01, "suffix:s") var tap_max_duration: float = 0.25

func _validate_property(property: Dictionary) -> void:
	if property.name == "threshold" and trigger_mode != TriggerMode.ON_THRESHOLD:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name == "tap_max_duration" and trigger_mode != TriggerMode.TAP_GESTURE:
		property.usage = PROPERTY_USAGE_NO_EDITOR

func is_held_type() -> bool:
	return trigger_mode == TriggerMode.ON_TOUCH \
		or trigger_mode == TriggerMode.CONTINUOUS \
		or trigger_mode == TriggerMode.ON_THRESHOLD

func should_hold_active(dist_fraction: float, stick_deadzone: float) -> bool:
	match trigger_mode:
		TriggerMode.ON_TOUCH:
			return true
		TriggerMode.CONTINUOUS:
			return dist_fraction >= stick_deadzone
		TriggerMode.ON_THRESHOLD:
			return dist_fraction >= threshold
		_:
			return false

func is_on_release() -> bool:
	return trigger_mode == TriggerMode.ON_RELEASE

func is_tap_gesture() -> bool:
	return trigger_mode == TriggerMode.TAP_GESTURE
