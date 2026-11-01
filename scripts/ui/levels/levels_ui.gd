extends Control

@onready var back: Button = $back


func _ready() -> void:
	back.pressed.connect(on_back_click)
	UiAnim.hover_scale(back, 1.04)
	UiAnim.slide_in(back, Vector2(0.0, 40.0), 0.4)


func on_back_click() -> void:
	SceneLoader.change_scene("res://scenes/main.tscn")
