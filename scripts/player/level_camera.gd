extends Camera3D

@export var player: CharacterBody3D;

var fall_rotation_degrees: Vector3 = Vector3(-33.5, 0.0, 0.0);
var rotation_speed: float = 3.0;

func _process(delta: float) -> void:
	var target_rotation: Quaternion;
	
	if player.fall_part.is_on_grass():
		var target_transform := global_transform.looking_at(
			player.global_position,
			Vector3.UP
		)

		target_rotation = target_transform.basis.get_rotation_quaternion()
	else:
		target_rotation = Quaternion.from_euler(
			fall_rotation_degrees * (PI / 180.0)
		);
		
	var weight := 1.0 - exp(-rotation_speed * delta)
	var current_rotation := global_basis.orthonormalized().get_rotation_quaternion()
	
	global_basis = Basis(
		current_rotation.slerp(target_rotation, weight)
	)
	
const START_SIZE: float = 9.0;

func _ready() -> void:
	size = START_SIZE;

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			set_camera_fov(false);
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			set_camera_fov(true);

const SIZE_SPEED: float = 2.0;
const MAX_SIZE_VALUE: float = 12.0;
const MIN_SIZE_VALUE: float = 6.0;

var camera_size: float = START_SIZE;

func set_camera_fov(num_is_true: bool) -> void:
	if num_is_true: camera_size += SIZE_SPEED;
	else: camera_size -= SIZE_SPEED;
	camera_size = clampf(camera_size, MIN_SIZE_VALUE, MAX_SIZE_VALUE);
	size = camera_size;
