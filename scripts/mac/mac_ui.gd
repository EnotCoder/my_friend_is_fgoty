extends Control

const EMPTY_TEXTURE := preload("res://ui/card_code_ui/null.png")

const DRAG_SCRIPT := preload("res://scripts/mac/texture_rect.gd")

## Число пустых слотов в правой панели («мой код»).
const RIGHT_EMPTY_SLOTS := 4

@onready var left_list: VBoxContainer = \
	$code_rect/code_list/MarginContainer/code_list

@onready var right_list: VBoxContainer = \
	$my_code_rect/scroll/MarginContainer/code_list

var code: Array[Texture] = [
	load("res://ui/card_code_ui/code_to_create_window.png"),
	load("res://ui/card_code_ui/code_to_import.png")
]

func load_all_code():
	# Карточки команд — в левую панель (к ним уже добавлены
	# пустые слоты code_1 / code_2 из сцены).
	for card in code:
		left_list.add_child(make_slot(card));

	# Пустые слоты — в правую панель.
	for i in RIGHT_EMPTY_SLOTS:
		right_list.add_child(make_slot(EMPTY_TEXTURE));

func make_slot(texture: Texture) -> TextureRect:
	var rect := TextureRect.new();

	rect.set_script(DRAG_SCRIPT)
	rect.texture = texture;

	return rect;
