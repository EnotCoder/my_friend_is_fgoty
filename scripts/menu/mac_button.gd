extends MeshInstance3D

@onready var area: Area3D = $area
@onready var rust: MeshInstance3D = $"../Rust"
@onready var text_to_play: Sprite3D = $text_to_play
@onready var mac_screen_off: MeshInstance3D = $mac_screen_off
@onready var mac_screen_on: MeshInstance3D = $mac_screen_on

var is_hover: bool = false;

func _ready() -> void:
	mac_screen_off.show();
	mac_screen_on.hide();
	
	area.mouse_entered.connect(rust.on_cursor_mac_entered);
	area.mouse_entered.connect(mac_screen_on_);
	area.mouse_entered.connect(text_to_play.on_cursor_mac_entered);
	
	area.mouse_exited.connect(rust.on_cursor_mac_exited);
	area.mouse_exited.connect(mac_screen_off_);
	area.mouse_exited.connect(text_to_play.on_cursor_mac_exited);

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_hover:
			on_mac_screen_click();
		
func on_mac_screen_click() -> void:
	get_tree().change_scene_to_file("res://scenes/level_1.tscn");

func mac_screen_on_() -> void:
	mac_screen_on.show();
	mac_screen_off.hide();
	
	is_hover = true;
	
func mac_screen_off_():
	mac_screen_on.hide();
	mac_screen_off.show();
	
	is_hover = false;
