extends MeshInstance3D

@onready var hint_label: Control = $hint_label

func sitting_click() -> void:
	hint_label.object_click("It's sitting!!!")
