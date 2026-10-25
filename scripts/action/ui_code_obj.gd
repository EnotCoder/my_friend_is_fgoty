extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var use: Button = $use
@onready var delete: Button = $delete
@onready var mac = $"../..".mac;
@onready var parent_parent = $"../..";
@onready var code: TextureRect = $code

func start():
	get_tree().paused = true	
	animation_player.play("fade_in");

func _ready() -> void:
	use.pressed.connect(pressed_use);
	delete.pressed.connect(pressed_delete);

func pressed_use():
	get_tree().paused = false;
	animation_player.play("fade_out");
	mac.add_code(code.texture);
	parent_parent.explode();
	
func pressed_delete():
	get_tree().paused = false;
	animation_player.play("fade_out");
