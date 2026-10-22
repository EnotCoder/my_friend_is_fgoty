extends MeshInstance3D

@onready var area: Area3D = $area
@onready var rust: MeshInstance3D = $"../Rust"
@onready var mac_screen_off: MeshInstance3D = $mac_screen_off
@onready var mac_screen_on: MeshInstance3D = $mac_screen_on

func _ready() -> void:
	mac_screen_off.show();
	mac_screen_on.hide();
	
	area.mouse_entered.connect(rust.on_cursor_mac_entered);
	area.mouse_entered.connect(mac_screen_on_);
	
	area.mouse_exited.connect(rust.on_cursor_mac_exited);
	area.mouse_exited.connect(mac_screen_off_);
	
func mac_screen_on_():
	mac_screen_on.show();
	mac_screen_off.hide();
	
func mac_screen_off_():
	mac_screen_on.hide();
	mac_screen_off.show();
