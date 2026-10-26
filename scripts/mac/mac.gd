extends MeshInstance3D

# function click
@onready var ui: Control = $ui;

func on_mac_click() -> void:
	get_tree().paused = true;
	ui.show();

func _ready() -> void:
	ui.hide();

# storage player's code
var code: Array[Texture] = [];

func add_code(texture: Texture):
	code.append(texture);
	ui.load_new_code(texture);
