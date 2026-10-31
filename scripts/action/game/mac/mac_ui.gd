extends Control

# load cards

const EMPTY_TEXTURE := preload("res://ui/card_code_ui/null.png")
const DRAG_SCRIPT := preload("res://scripts/action/game/mac/texture_rect.gd")

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
	
	_apply_mac_style($code_rect)
	_apply_mac_style($my_code_rect)
	
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


func _apply_mac_style(panel: ColorRect) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.8) # Полупрозрачный темный
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	
	# Тонкая рамка «стекла»
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color(1, 1, 1, 0.15)
	
	# Мягкая тень
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = 12
	style.shadow_offset = Vector2(0, 8)
	
	# Применяем через Panel, если это возможно, или заменим ColorRect на Panel
	# Но так как у нас ColorRect, мы можем добавить Panel как фон
	var bg_panel = Panel.new()
	bg_panel.add_theme_stylebox_override("panel", style)
	bg_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg_panel.show_behind_parent = true
	bg_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(bg_panel)
	
	# Сделаем сам ColorRect прозрачным, так как теперь есть Panel
	panel.color.a = 0

