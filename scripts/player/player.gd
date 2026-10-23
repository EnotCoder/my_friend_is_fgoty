extends CharacterBody3D

const SPEED = 5.0;
const ROT_SPEED: float = 10.0;

@onready var visual: Node3D = $Rust;
var target_angle: float = 0.0;


func _ready() -> void:
	target_angle = visual.rotation.y;


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

	move_and_slide();
