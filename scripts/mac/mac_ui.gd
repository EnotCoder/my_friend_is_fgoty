extends Control

# load cards

const EMPTY_TEXTURE := preload("res://ui/card_code_ui/null.png")
const DRAG_SCRIPT := preload("res://scripts/mac/texture_rect.gd")

## Число пустых слотов в правой панели («мой код»).
var right_empty_slots := 2;

@onready var left_list: VBoxContainer = \
	$code_rect/code_list/MarginContainer/code_list

@onready var right_list: VBoxContainer = \
	$my_code_rect/scroll/MarginContainer/code_list

@onready var mac: MeshInstance3D = $".."
@onready var win_lose_level: Control = $"../win_lose_level"

func load_new_code(card: Texture):
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
	run_code.pressed.connect(on_run_pressed)
	
	right_empty_slots = mac.finish_code.size();
	
	for i in right_empty_slots:
		left_list.add_child(make_slot(EMPTY_TEXTURE));
	
func on_back_pressed() -> void:
	get_tree().paused = false;
	hide();
	
func on_run_pressed() -> void:
	get_tree().paused = false;
	hide();
	
	var i = 0;
	for item in left_list.get_children():
		if item.texture != mac.finish_code[i]:
			win_lose_level.lose_level();
			return
		i += 1;
		
	win_lose_level.win_level();
	
