extends Control

# load cards

const EMPTY_TEXTURE := preload("res://ui/card_code_ui/null.png")
const DRAG_SCRIPT := preload("res://scripts/mac/texture_rect.gd")

## Число пустых слотов в правой панели («мой код»).
const RIGHT_EMPTY_SLOTS := 4;

@onready var left_list: VBoxContainer = \
	$code_rect/code_list/MarginContainer/code_list

@onready var right_list: VBoxContainer = \
	$my_code_rect/scroll/MarginContainer/code_list

@onready var mac: MeshInstance3D = $".."


func load_all_code():
	for child in right_list.get_children():
		child.queue_free()
	
	for card in mac.code:
		right_list.add_child(make_slot(card));

func make_slot(texture: Texture) -> TextureRect:
	var rect := TextureRect.new();

	rect.set_script(DRAG_SCRIPT)
	rect.texture = texture;

	return rect;

# button connect
@onready var back: Button = $back
@onready var run_code: Button = $run_code


func _ready() -> void:
	back.pressed.connect(on_back_pressed)
	for i in RIGHT_EMPTY_SLOTS:
		left_list.add_child(make_slot(EMPTY_TEXTURE));
	
func on_back_pressed() -> void:
	get_tree().paused = false;
	hide();
