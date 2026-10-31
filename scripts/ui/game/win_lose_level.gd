extends Control

@onready var win: Control = $win
@onready var lose: Control = $lose

@onready var back: Button = $back

func _ready() -> void:
	back.pressed.connect(on_back_pressed)
	
	hide()
	win.hide()
	lose.hide()
	

func win_level() -> void:
	get_tree().paused = true
	show()
	win.show()

func lose_level() -> void:
	get_tree().paused = true
	show()
	lose.show()
	
func on_back_pressed() -> void:
	get_tree().paused = false
	SceneLoader.change_scene("res://scenes/levels/levels.tscn")
