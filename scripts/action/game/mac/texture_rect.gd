extends TextureRect

var empty_texture: Texture2D


func setup(empty_tex: Texture2D) -> void:
	empty_texture = empty_tex
	# PASS: с контрола стартует drag, но дроп при этом «поднимается»
	# выше к ScrollContainer со скриптом code_panel.gd.
	mouse_filter = Control.MOUSE_FILTER_PASS


func is_empty() -> bool:
	return texture == null or texture == empty_texture


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
