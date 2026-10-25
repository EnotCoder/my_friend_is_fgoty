extends TextureRect

const EMPTY_TEXTURE := preload("res://ui/card_code_ui/null.png")


func _ready() -> void:
	# PASS: с контрола стартует drag, но дроп при этом «поднимается»
	# выше к ScrollContainer со скриптом code_panel.gd.
	mouse_filter = Control.MOUSE_FILTER_PASS;


func is_empty() -> bool:
	return texture == null or texture == EMPTY_TEXTURE


func _get_drag_data(_at_position: Vector2) -> Variant:
	# Пустой слот перетаскивать нельзя.
	if is_empty():
		return null;

	# Картинка, которая будет следовать за курсором.
	var preview := TextureRect.new();
	preview.texture = texture;
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE;
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED;
	preview.size = Vector2(240.0, 160.0);
	preview.modulate.a = 0.8;
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE;

	set_drag_preview(preview);

	return {
		"type": "code_card",
		"texture": texture,
		"source": self
	};
