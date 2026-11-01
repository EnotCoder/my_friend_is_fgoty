extends Control

@export var level_goal: String
@export var level_part_counter: int
@export var ex_level_part_counter: int

@onready var but_close: Button = $panel/but_close
@onready var goal: Label = $panel/goal
@onready var part_counter: Label = $panel/part_counter
@onready var warn: Label = $panel/warn
@onready var about_exit: Label = $panel/about_exit
@onready var panel: Control = $panel
@onready var hint_button: TextureButton = $hint

@onready var music: AudioStreamPlayer = $sounds/music
@onready var click_but: AudioStreamPlayer = $sounds/click_but


func _ready() -> void:
	but_close.pressed.connect(hide_hint)

	goal.text = level_goal
	part_counter.text = \
		"Your code should consist of " + str(level_part_counter) \
		+ " parts (" + str(ex_level_part_counter) + " is extra)"

	_pulse_hint_button()
	show_hint()


func hide_hint() -> void:
	get_tree().paused = false
	music.stop()

	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, 0.18)
	tween.tween_callback(panel.hide)


func show_hint() -> void:
	get_tree().paused = true
	panel.show()
	_animate_panel_in()
	music.play()
	click_but.play()


func _animate_panel_in() -> void:
	panel.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.25)

	UiAnim.slide_in(goal, Vector2(0.0, 40.0), 0.35, 0.05)
	UiAnim.slide_in(part_counter, Vector2(0.0, 50.0), 0.35, 0.1)
	UiAnim.slide_in(warn, Vector2(0.0, 60.0), 0.35, 0.15)
	UiAnim.slide_in(about_exit, Vector2(0.0, 70.0), 0.35, 0.2)


func _pulse_hint_button() -> void:
	var base := hint_button.scale
	var target := base * 1.1

	var tween := create_tween().set_loops()
	tween.tween_property(hint_button, "scale", target, 0.8) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(hint_button, "scale", base, 0.8) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
