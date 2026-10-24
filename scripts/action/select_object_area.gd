extends Area3D;

@export var shader_obj: Array[Node3D] = [];
@export var select_material: ShaderMaterial;
@export var call_func_click: String;

var is_hover: bool = false;
var current_opacity: float = 0.0;

const SPEED_FADE: float = 5.0;

var meshes: Array[MeshInstance3D] = [];

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
		if event.pressed \
				and event.button_index == MOUSE_BUTTON_LEFT \
				and is_hover:
			var parent := get_parent();

			if is_instance_valid(parent) \
					and parent.has_method(call_func_click):
				if not World.is_show_hint:
					parent.call(call_func_click);
					World.is_show_hint = true;
				else:
					print("wait");
			else:
				print("obj not has this func '", call_func_click, "'");


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
