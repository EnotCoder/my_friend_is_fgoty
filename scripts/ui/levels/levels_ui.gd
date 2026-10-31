extends Control

@onready var back: Button = $back

func _ready() -> void:
	back.pressed.connect(on_back_click)

func on_back_click() -> void:
	SceneLoader.change_scene("res://scenes/main.tscn")
