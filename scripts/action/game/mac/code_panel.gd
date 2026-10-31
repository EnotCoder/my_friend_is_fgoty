extends ScrollContainer

@onready var code_list: VBoxContainer = $MarginContainer/code_list

# Статическая переменная общая для всех панелей (левой и правой)
static var global_hovered_slot: TextureRect = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	# Настройка фильтров мыши для корректной работы Drag&Drop
	_setup_mouse_filters(self)


func _setup_mouse_filters(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			if child is TextureRect:
				child.mouse_filter = Control.MOUSE_FILTER_STOP
			else:
				child.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_setup_mouse_filters(child)


func is_empty_slot(slot: TextureRect) -> bool:
	if slot.has_method("is_empty"):
		return slot.is_empty()
	return slot.texture == null


func get_empty_slot() -> TextureRect:
	for child in code_list.get_children():
		if child is TextureRect and is_empty_slot(child):
			return child
	return null


func get_slot_under_cursor() -> TextureRect:
	var cursor := get_global_mouse_position()
	for child in code_list.get_children():
		if child is TextureRect and child.get_global_rect().has_point(cursor):
			return child
	return null


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if not data is Dictionary:
		return false

	var can_drop = (
		data.get("type") == "code_card"
		and data.get("texture") is Texture2D
		and get_empty_slot() != null
	)

	var current_slot = get_slot_under_cursor()

	if current_slot != global_hovered_slot:
		if global_hovered_slot and is_instance_valid(global_hovered_slot):
			_animate_slot(global_hovered_slot, false)
		
		if current_slot and is_empty_slot(current_slot):
			_animate_slot(current_slot, true)
			global_hovered_slot = current_slot
		else:
			global_hovered_slot = null

	return can_drop


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		if global_hovered_slot and is_instance_valid(global_hovered_slot):
			_animate_slot(global_hovered_slot, false)
		global_hovered_slot = null


func _animate_slot(slot: TextureRect, active: bool) -> void:
	var tween = slot.create_tween()
	if active:
		tween.tween_property(slot, "modulate", Color(1.5, 1.5, 1.5, 1.0), 0.1)
	else:
		tween.tween_property(slot, "modulate", Color.WHITE, 0.1)


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if global_hovered_slot:
		_animate_slot(global_hovered_slot, false)
		global_hovered_slot = null

	var slot := get_slot_under_cursor()
	if slot == null or not is_empty_slot(slot):
		slot = get_empty_slot()

	if slot == null:
		return

	var source = data.get("source") as TextureRect
	var texture = data.get("texture") as Texture2D

	slot.texture = texture

	# Если в TextureRect есть ссылка на пустую текстуру, используем её
	if is_instance_valid(source) and source != slot:
		if "empty_texture" in source:
			source.texture = source.empty_texture
		else:
			source.texture = null

