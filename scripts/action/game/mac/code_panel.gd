extends ScrollContainer

const EMPTY_TEXTURE := preload("res://ui/card_code_ui/null.png")

const DRAG_SCRIPT := preload("res://scripts/action/game/mac/texture_rect.gd")

@onready var code_list: VBoxContainer = $MarginContainer/code_list


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_setup_mouse_filters(self)

func _setup_mouse_filters(node: Node) -> void:
	for child in node.get_children():
		var control := child as Control

		if control != null:
			if control is TextureRect:
				control.mouse_filter = Control.MOUSE_FILTER_STOP
			else:
				control.mouse_filter = Control.MOUSE_FILTER_IGNORE

		_setup_mouse_filters(child)


func is_empty_slot(slot: TextureRect) -> bool:
	return slot.texture == null or slot.texture == EMPTY_TEXTURE


func get_empty_slot() -> TextureRect:
	for child in code_list.get_children():
		if child is TextureRect and is_empty_slot(child):
			return child

	return null


## Слот под курсором (для точного дропа в конкретную ячейку).
func get_slot_under_cursor() -> TextureRect:
	var cursor := get_global_mouse_position()

	for child in code_list.get_children():
		if child is TextureRect and child.get_global_rect().has_point(cursor):
			return child

	return null


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if not data is Dictionary:
		return false

	return (
		data.get("type") == "code_card"
		and data.get("texture") is Texture2D
		and get_empty_slot() != null
	)


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var slot := get_slot_under_cursor()

	if slot == null or not is_empty_slot(slot):
		slot = get_empty_slot()

	if slot == null:
		return

	var source := data.get("source") as TextureRect

	# Заполняем цель текстурой источника.
	if data.get("texture") is Texture2D:
		slot.texture = data["texture"]

	# Освобождаем источник: он становится пустым слотом (перемещение, не удаление).
	if is_instance_valid(source) and source != slot:
		source.texture = EMPTY_TEXTURE
