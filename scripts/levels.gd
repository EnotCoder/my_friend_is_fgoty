extends Node3D

const DRAG_SPEED: float = 0.003;
const SMOOTH_SPEED: float = 12.0

var MIN_X: float = 0.0;
var MAX_X: float = -2.8;

var target_x: float = 0.0;

func _input(event: InputEvent) -> void:
	var pos_x: float = target_x;
	
	if event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			pos_x += event.relative.x * DRAG_SPEED;
			
			target_x = clampf(pos_x, MAX_X, MIN_X);

func _process(delta: float) -> void:
	position.x = lerpf(
		position.x,
		target_x,
		1.0 - exp(-SMOOTH_SPEED * delta)
	);
	
func start_level_1():
	SceneLoader.change_scene("res://scenes/levels/level_1.tscn");

func start_level_2():
	SceneLoader.change_scene("res://scenes/levels/level_2.tscn");
	
func start_level_3():
	SceneLoader.change_scene("res://scenes/levels/level_3.tscn");
