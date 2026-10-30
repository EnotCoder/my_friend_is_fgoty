extends CharacterBody3D

class_name Player;

const SPEED = 5.0;
const ROT_SPEED: float = 10.0;

@onready var visual: Node3D = $Rust;
var target_angle: float = 0.0;

@onready var fall_part: Node3D = $fall_part
@onready var standart_level_position: Vector3 = global_position;
@onready var walk: AudioStreamPlayer = $sounds/walk

var walk_time: float = 0.0
var start_rotation_x: float
var walk_angle: float = 20.0
var walk_frequency: float = 3.0

func set_standart_level_position():
	global_position = standart_level_position;
	global_position.y = standart_level_position.y + 10.0;

@export var is_apk: bool = false;
@onready var moble_ui: Control = $moble_ui

@onready var part: CPUParticles3D = $part

func _ready() -> void:
	target_angle = visual.rotation.y;
	start_rotation_x = visual.rotation.x;
	setup_crab_xray();
	
	if is_apk:
		moble_ui.show();
	else:
		moble_ui.hide();


func _physics_process(dt: float) -> void:
	add_player_gravity(dt);
	player_move(dt);
	
	if Input.is_action_just_pressed("Exit"):
		get_tree().change_scene_to_file("res://scenes/levels/levels.tscn");


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
	var is_walking := direction != Vector3.ZERO and is_on_floor()

	if is_walking:
		walk_time += dt
		part.emitting = true

		# Запускаем только тогда, когда звук ещё не играет.
		if not walk.playing:
			walk.play()

		target_x += (
			sin(walk_time * TAU * walk_frequency)
			* deg_to_rad(walk_angle)
		)
	else:
		part.emitting = false

		if walk.playing:
			walk.stop()

		walk_time = 0.0

	visual.rotation.x = lerp_angle(
		visual.rotation.x,
		target_x,
		weight
	)

	move_and_slide()
	
func setup_crab_xray() -> void:
	var crab := visual as MeshInstance3D

	if not is_instance_valid(crab) or crab.mesh == null:
		return

	for surface_id in range(crab.mesh.get_surface_count()):
		var original := crab.get_active_material(surface_id) as BaseMaterial3D

		if original == null:
			continue

		var material := original.duplicate() as BaseMaterial3D

		material.stencil_mode = BaseMaterial3D.STENCIL_MODE_XRAY
		material.stencil_color = Color(0.05, 0.3, 1.0, 0.7)

		crab.set_surface_override_material(surface_id, material)
