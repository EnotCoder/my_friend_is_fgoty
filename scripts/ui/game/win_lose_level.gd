extends Control

@onready var win: Control = $win
@onready var lose: Control = $lose
@onready var back: Button = $back
@onready var rect: ColorRect = $rect
@onready var win_text: Label = $win/text
@onready var lose_text: Label = $lose/text


func _ready() -> void:
	back.pressed.connect(on_back_pressed)

	hide()
	win.hide()
	lose.hide()

	UiAnim.hover_scale(back, 1.04)


func win_level() -> void:
	get_tree().paused = true
	show()
	win.show()
	lose.hide()

	_fade_backdrop()
	UiAnim.pop_in(win_text, 0.5, 0.4)
	UiAnim.slide_in(back, Vector2(0.0, 40.0), 0.35, 0.15)


func lose_level() -> void:
	get_tree().paused = true
	show()
	lose.show()
	win.hide()

	_fade_backdrop()
	UiAnim.pop_in(lose_text, 0.4, 0.4)
	UiAnim.shake(lose_text, 14.0)
	UiAnim.slide_in(back, Vector2(0.0, 40.0), 0.35, 0.25)


func _fade_backdrop() -> void:
	var target := Color(0.0, 0.0, 0.0, 0.4627451)
	rect.color = Color(target.r, target.g, target.b, 0.0)

	var tween := create_tween()
	tween.tween_property(rect, "color", target, 0.25)


func on_back_pressed() -> void:
	get_tree().paused = false
	SceneLoader.change_scene("res://scenes/levels/levels.tscn")
