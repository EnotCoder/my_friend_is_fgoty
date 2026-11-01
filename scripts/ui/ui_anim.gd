class_name UiAnim
extends RefCounted

## Небольшие переиспользуемые UI-анимации на основе Tween.


static func center_pivot(control: Control) -> void:
	control.pivot_offset = control.size / 2.0


## Появление с масштабом и плавным проявлением.
static func pop_in(
	control: Control,
	duration: float = 0.4,
	from_scale: float = 0.4,
	delay: float = 0.0
) -> void:
	center_pivot(control)
	control.scale = Vector2.ONE * from_scale
	control.modulate.a = 0.0

	var tween := control.create_tween().set_parallel(true)
	tween.tween_property(control, "scale", Vector2.ONE, duration) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(delay)
	tween.tween_property(control, "modulate:a", 1.0, duration * 0.6) \
		.set_delay(delay)


## Выдвижение из смещённого положения с проявлением.
static func slide_in(
	control: Control,
	offset: Vector2 = Vector2(0.0, 40.0),
	duration: float = 0.35,
	delay: float = 0.0
) -> void:
	var target := control.position
	control.position = target + offset
	control.modulate.a = 0.0

	var tween := control.create_tween().set_parallel(true)
	tween.tween_property(control, "position", target, duration) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_delay(delay)
	tween.tween_property(control, "modulate:a", 1.0, duration * 0.7) \
		.set_delay(delay)


## Короткое дрожание (например, при проигрыше).
static func shake(control: Control, strength: float = 16.0, times: int = 4) -> void:
	var base := control.position
	var tween := control.create_tween()

	for i in times:
		var direction := 1.0 if i % 2 == 0 else -1.0
		tween.tween_property(
			control,
			"position",
			base + Vector2(strength * direction, 0.0),
			0.05
		)

	tween.tween_property(control, "position", base, 0.08)


## Увеличение контрола при наведении курсора.
static func hover_scale(control: Control, scale_amount: float = 1.05) -> void:
	control.mouse_entered.connect(_on_hover.bind(control, scale_amount))
	control.mouse_exited.connect(_on_hover.bind(control, 1.0))


static func _on_hover(control: Control, scale_amount: float) -> void:
	if not is_instance_valid(control):
		return

	center_pivot(control)
	var tween := control.create_tween()
	tween.tween_property(control, "scale", Vector2.ONE * scale_amount, 0.12) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


## Бесконечное лёгкое покачивание вокруг центра.
static func wobble(control: Control, degrees: float = 1.5, duration: float = 2.0) -> Tween:
	center_pivot(control)
	var tween := control.create_tween().set_loops()
	tween.tween_property(control, "rotation_degrees", degrees, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(control, "rotation_degrees", -degrees, duration) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween
