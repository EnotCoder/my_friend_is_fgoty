extends Node3D

@onready var need_card = $"../Mac".finish_code.size();

var get_all: bool = false;

func _process(_delta: float) -> void:
	var i := 0;
	for child in get_children():
		if child.is_get == false:
			i += 1;
			
	if i < need_card and not get_all:
		for child in get_children():
			if child.is_get == false:
				child.del();
				child.explode();
				get_all = true;
