extends TextureRect

var empty_texture: Texture2D

var _hover_tween: Tween
var _highlight_tween: Tween


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func setup(empty_tex: Texture2D) -> void:
	empty_texture = empty_tex
	# PASS: с контрола стартует drag, но дроп при этом «поднимается»
	# выше к ScrollContainer со скриптом code_panel.gd.
	mouse_filter = Control.MOUSE_FILTER_PASS


func is_empty() -> bool:
	return texture == null or texture == empty_texture


## Анимация появления новой карточки.
func play_spawn() -> void:
	stop_animations()
	pivot_offset = size / 2.0
	scale = Vector2(0.6, 0.6)
	modulate.a = 0.0

	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ONE, 0.3) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.2)


## Подсветка слота, когда над ним находится перетаскиваемая карточка.
func play_highlight(active: bool) -> void:
	if _highlight_tween and _highlight_tween.is_valid():
		_highlight_tween.kill()

	var target := Color(1.5, 1.5, 1.5, 1.0) if active else Color.WHITE

	_highlight_tween = create_tween()
	_highlight_tween.tween_property(self, "modulate", target, 0.1)


func stop_animations() -> void:
	stop_hover_animation()

	if _highlight_tween and _highlight_tween.is_valid():
		_highlight_tween.kill()


func stop_hover_animation() -> void:
	if _hover_tween and _hover_tween.is_valid():
		_hover_tween.kill()


func _on_mouse_entered() -> void:
	if is_empty():
		return
	_animate_scale(1.05)


func _on_mouse_exited() -> void:
	_animate_scale(1.0)


func _animate_scale(value: float) -> void:
	if _hover_tween and _hover_tween.is_valid():
		_hover_tween.kill()

	pivot_offset = size / 2.0
	_hover_tween = create_tween()
	_hover_tween.tween_property(self, "scale", Vector2.ONE * value, 0.12) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _get_drag_data(_at_position: Vector2) -> Variant:
	if is_empty():
		return null

	# Картинка, которая будет следовать за курсором.
	var preview := TextureRect.new()
	preview.texture = texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.size = Vector2(240.0, 160.0)
	preview.pivot_offset = preview.size / 2
	preview.modulate.a = 0.0
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE

	set_drag_preview(preview)

	var tween = preview.create_tween().set_parallel(true)
	tween.tween_property(preview, "modulate:a", 0.9, 0.2)
	tween.tween_property(preview, "scale", Vector2(1.1, 1.1), 0.2)
	tween.tween_property(preview, "rotation_degrees", 5.0, 0.2)

	return {
		"type": "code_card",
		"texture": texture,
		"source": self
	}
