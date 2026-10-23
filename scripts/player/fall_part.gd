extends Node3D

const GLOBAL_FALL_LINE: float = -4.408;
const GLOBAL_TP_FALL_LINE: float = -16.408;

func _process(_delta: float) -> void:
	if get_parent().global_position.y <= GLOBAL_TP_FALL_LINE:
		get_parent().set_standart_level_position();

func is_on_grass() -> bool:
	if get_parent().global_position.y <= GLOBAL_FALL_LINE:
		return false;
	
	return true;
