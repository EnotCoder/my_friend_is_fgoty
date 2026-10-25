extends MeshInstance3D

@onready var ui: Control = $ui
@onready var back: Button = $ui/back

func on_mac_click() -> void:
	get_tree().paused = true;
	ui.show();

func _ready() -> void:
	back.pressed.connect(on_back_pressed)
	ui.hide();
	ui.load_all_code()
	
func on_back_pressed() -> void:
	get_tree().paused = false;
	ui.hide();
	
