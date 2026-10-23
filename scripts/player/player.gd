extends CharacterBody3D

const SPEED = 5.0;
const ROT_SPEED: float = 10.0;

@onready var visual: Node3D = $Rust;
var target_angle: float = 0.0;

@onready var fall_part: Node3D = $fall_part
@onready var standart_level_position: Vector3 = global_position;

var walk_time: float = 0.0
var start_rotation_x: float
var walk_angle: float = 20.0
var walk_frequency: float = 3.0

func set_standart_level_position():
	global_position = standart_level_position;

func _ready() -> void:
	target_angle = visual.rotation.y;
	start_rotation_x = visual.rotation.x;


func _physics_process(dt: float) -> void:
	add_player_gravity(dt);
	player_move(dt);


func add_player_gravity(dt: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * dt;


func player_move(dt: float) -> void:
	var input_dir := Input.get_vector("A", "D", "W", "S");
	var direction := Vector3(input_dir.x, 0.0, input_dir.y).normalized();
	
	

	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED;
		velocity.z = direction.z * SPEED;

		target_angle = atan2(-direction.x, -direction.z) + PI;
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED);
		velocity.z = move_toward(velocity.z, 0.0, SPEED);

	var weight := 1.0 - exp(-ROT_SPEED * dt);
	visual.rotation.y = lerp_angle(
		visual.rotation.y,
		target_angle,
		weight
	);
	
	# walk animation
	var target_x := start_rotation_x

	if direction != Vector3.ZERO and is_on_floor():
		walk_time += dt

		target_x += sin(walk_time * TAU * walk_frequency) * deg_to_rad(walk_angle)
	else:
		walk_time = 0.0

	visual.rotation.x = lerp_angle(
		visual.rotation.x,
		target_x,
		weight
	)

	move_and_slide();
