extends Node3D

const GLOBAL_FALL_LINE: float = -4.408;
const GLOBAL_TP_FALL_LINE: float = -30.408;

@onready var animation_player: AnimationPlayer = $ui/AnimationPlayer
@onready var fall: AudioStreamPlayer = $"../sounds/fall"
@onready var tp: AudioStreamPlayer = $"../sounds/tp"

var show_ui: bool = false;

func _process(_delta: float) -> void:
	if get_parent().global_position.y <= GLOBAL_TP_FALL_LINE:
		get_parent().set_standart_level_position();
		show_ui = false;
		animation_player.play("fade_out");
		tp.play();

func is_on_grass() -> bool:
	if get_parent().global_position.y <= GLOBAL_FALL_LINE:
		if not show_ui:
			animation_player.play("fade_in");
			show_ui = true;
			fall.play();
		return false;
	
	return true;
