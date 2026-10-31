extends Control

## Текстура пустого слота.
@export var empty_slot_texture: Texture2D = preload("res://ui/card_code_ui/null.png")

const DRAG_SCRIPT = preload("res://scripts/action/game/mac/texture_rect.gd")

@onready var left_list: VBoxContainer = $code_rect/code_list/MarginContainer/code_list
@onready var right_list: VBoxContainer = $my_code_rect/scroll/MarginContainer/code_list
@onready var back_button: Button = $back
@onready var run_button: Button = $run_code

# Ссылки на внешние узлы
@onready var mac: MeshInstance3D = get_parent()
@onready var win_lose_level: Control = get_node("../win_lose_level")

var expected_slots_count: int = 0


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	run_button.pressed.connect(_on_run_pressed)
	
	expected_slots_count = mac.finish_code.size()
	
	# Стилизация панелей под Mac
	_apply_mac_style($code_rect)
	_apply_mac_style($my_code_rect)
	
	# Инициализация пустых слотов в левой панели (куда вставляем код)
	for i in expected_slots_count:
		left_list.add_child(create_code_slot(empty_slot_texture))


## Создает новый узел слота с поддержкой Drag & Drop.
func create_code_slot(tex: Texture2D) -> TextureRect:
	var rect := TextureRect.new()
	rect.set_script(DRAG_SCRIPT)
	rect.texture = tex
	# Передаем ссылку на пустую текстуру, чтобы слот знал, что он пустой
	if rect.has_method("setup"):
		rect.setup(empty_slot_texture)
	return rect


## Добавляет карточку в правую панель (инвентарь).
func load_new_code(card_texture: Texture2D) -> void:
	right_list.add_child(create_code_slot(card_texture))


func _on_back_pressed() -> void:
	get_tree().paused = false
	hide()


func _on_run_pressed() -> void:
	get_tree().paused = false
	hide()
	
	var current_slots = left_list.get_children()
	
	# Проверка на соответствие собранного кода правильному массиву
	for i in range(expected_slots_count):
		var slot = current_slots[i] as TextureRect
		if slot.texture != mac.finish_code[i]:
			win_lose_level.lose_level()
			return
			
	win_lose_level.win_level()


func _apply_mac_style(panel: ColorRect) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(1, 1, 1, 0.15)
	
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = 12
	style.shadow_offset = Vector2(0, 8)
	
	var bg_panel = Panel.new()
	bg_panel.add_theme_stylebox_override("panel", style)
	bg_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg_panel.show_behind_parent = true
	bg_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(bg_panel)
	
	panel.color.a = 0

