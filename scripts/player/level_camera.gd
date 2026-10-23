extends Camera3D

@export var player: CharacterBody3D;

func _process(_delta: float) -> void:
	look_at(player.global_position);
const START_FOV: float = 30.0;

func _ready() -> void:
	fov = START_FOV;

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			set_camera_fov(false);
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			set_camera_fov(true);

const FOV_SPEED: float = 5.0;
const MAX_FOV_VALUE: float = 64.0;
const MIN_FOV_VALUE: float = 20.0;

var camera_fov: float = START_FOV;

func set_camera_fov(num_is_true: bool) -> void:
	if num_is_true: camera_fov += FOV_SPEED;
	else: camera_fov -= FOV_SPEED;
	camera_fov = clampf(camera_fov, MIN_FOV_VALUE, MAX_FOV_VALUE);
	fov = camera_fov;
