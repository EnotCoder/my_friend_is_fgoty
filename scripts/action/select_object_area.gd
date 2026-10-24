extends Area3D;

@export var shader_obj: Array[Node3D] = [];
@export var script_obj: Node3D;
@export var select_material: ShaderMaterial;
@export var call_func_click: String;

var is_hover: bool = false;
var current_opacity: float = 0.0;

const SPEED_FADE: float = 5.0;

var meshes: Array[MeshInstance3D] = [];

@export var click_threshold: float = 8.0

var click_started: bool = false
var was_dragged: bool = false
var press_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	for obj in shader_obj:
		if not is_instance_valid(obj):
			continue;

		if obj is MeshInstance3D:
			add_mesh(obj as MeshInstance3D);

		for child in obj.find_children("*", "MeshInstance3D", true, false):
			add_mesh(child as MeshInstance3D);

	set_select_opacity(current_opacity);

	mouse_entered.connect(show_select_shader)
	mouse_exited.connect(hide_select_shader);


func add_mesh(mesh: MeshInstance3D) -> void:
	if meshes.has(mesh):
		return;

	meshes.append(mesh);

	var material: ShaderMaterial = select_material;

	if material == null:
		material = mesh.material_overlay as ShaderMaterial;
	else:
		mesh.material_overlay = material.duplicate() as ShaderMaterial;

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return

		if event.pressed:
			click_started = is_hover
			was_dragged = false
			press_position = event.position

		else:
			var distance := press_position.distance_to(event.position)

			var should_click := (
				click_started
				and not was_dragged
				and distance <= click_threshold
			)

			click_started = false
			was_dragged = false

			if not should_click:
				return

			var parent := get_parent() if not script_obj else script_obj;

			if not is_instance_valid(parent):
				push_warning("У Area3D нет родителя")
				return

			if call_func_click.is_empty():
				push_warning("В инспекторе не заполнен Call Func Click")
				return

			if not parent.has_method(call_func_click):
				push_warning(
					"У родителя '%s' нет функции '%s'"
					% [parent.name, call_func_click]
				)
				return

			parent.call(call_func_click)

	elif event is InputEventMouseMotion:
		if click_started:
			var distance := press_position.distance_to(event.position)

			if distance > click_threshold:
				was_dragged = true

func show_select_shader() -> void:
	is_hover = true;


func hide_select_shader() -> void:
	is_hover = false;


func _process(delta: float) -> void:
	var target_opacity: float = 1.0 if is_hover else 0.0;

	current_opacity = move_toward(
		current_opacity,
		target_opacity,
		delta * SPEED_FADE
	);

	set_select_opacity(current_opacity);


func set_select_opacity(value: float) -> void:
	for mesh in meshes:
		if not is_instance_valid(mesh):
			continue;

		var material := mesh.material_overlay as ShaderMaterial;

		if material != null:
			material.set_shader_parameter("opacity", value);
