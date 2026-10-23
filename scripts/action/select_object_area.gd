extends Area3D

@export var shader_obj: Array[MeshInstance3D];

func _ready() -> void:
	for obj in shader_obj:
		if not is_instance_valid(obj):
			continue

		if obj.material_overlay is ShaderMaterial:
			obj.material_overlay = obj.material_overlay.duplicate()

	set_select_opacity(0.0)

	mouse_entered.connect(show_select_shader)
	mouse_exited.connect(hide_select_shader)

func show_select_shader() -> void:
	set_select_opacity(1.0)


func hide_select_shader() -> void:
	set_select_opacity(0.0)


func set_select_opacity(value: float) -> void:
	for obj in shader_obj:
		if not is_instance_valid(obj):
			continue

		var material := obj.material_overlay as ShaderMaterial

		if material:
			material.set_shader_parameter("opacity", value)
