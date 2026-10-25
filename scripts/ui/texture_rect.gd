extends TextureRect


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP


func _get_drag_data(_at_position: Vector2) -> Variant:
	if texture == null:
		return null

	# Картинка, которая будет следовать за курсором.
	var preview := TextureRect.new()
	preview.texture = texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.size = Vector2(240.0, 160.0)
	preview.modulate.a = 0.8
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE

	set_drag_preview(preview)

	return {
		"type": "code_card",
		"texture": texture,
		"source": self
	}
