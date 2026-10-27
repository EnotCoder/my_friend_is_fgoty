extends Control

@onready var back: Button = $back

func _ready() -> void:
	back.pressed.connect(on_back_click)

func on_back_click() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn");
