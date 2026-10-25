extends Control

@onready var my_code_rect := \
	$my_code_rect/scroll/MarginContainer/code_list;

var code: Array[Texture] = [
	load("res://ui/card_code_ui/code_to_create_window.png"),
	load("res://ui/card_code_ui/code_to_import.png")
]

func load_all_code():
	for i in code:
		my_code_rect.add_child(load_part_code(i));

const DRAG_SCRIPT = preload("res://scripts/ui/texture_rect.gd");

func load_part_code(index: Texture) -> TextureRect:
	var rect = TextureRect.new();
	
	rect.set_script(DRAG_SCRIPT)
	rect.texture = index;
	
	return rect;
