extends Area3D

@export var shader_obj: Array[MeshInstance3D];
@export var call_func_click: String;

var is_hover: bool = false;
var current_opacity: float = 0.0
const SPEED_FADE: float = 5.0;

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and is_hover:
			var parent := get_parent()
			if is_instance_valid(parent) and parent.has_method(call_func_click):
				parent.call(call_func_click)
			else:
				print("obj not has this func '", call_func_click, "'")

func _ready() -> void:
	for obj in shader_obj:
		if not is_instance_valid(obj):
			continue

		if obj.material_overlay is ShaderMaterial:
			obj.material_overlay = obj.material_overlay.duplicate()

	set_select_opacity(current_opacity)

	mouse_entered.connect(show_select_shader)
	mouse_exited.connect(hide_select_shader)

func show_select_shader() -> void:
	is_hover = true;

func hide_select_shader() -> void:
	is_hover = false;

func _process(delta: float) -> void:
	var target_opanticy: float = 1.0 if is_hover else 0.0;
	
	current_opacity = move_toward(
		current_opacity, target_opanticy, 
		delta * SPEED_FADE
	);
	
	set_select_opacity(current_opacity);

func set_select_opacity(value: float) -> void:
	for obj in shader_obj:
		if not is_instance_valid(obj):
			continue

		var material := obj.material_overlay as ShaderMaterial

		if material:
			material.set_shader_parameter("opacity", value)
