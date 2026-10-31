extends Control

@export var level_goal: String
@export var level_part_counter: int
@export var ex_level_part_counter: int

@onready var but_close: Button = $panel/but_close
@onready var goal: Label = $panel/goal
@onready var part_counter: Label = $panel/part_counter
@onready var panel: Control = $panel

@onready var music: AudioStreamPlayer = $sounds/music
@onready var click_but: AudioStreamPlayer = $sounds/click_but

func _ready() -> void:
	show_hint()
	but_close.pressed.connect(hide_hint)
	
	goal.text = level_goal
	part_counter.text = \
	"Your code should consist of "+str(level_part_counter)\
	+" parts ("+str(ex_level_part_counter)+" is extra)"

func hide_hint():
	get_tree().paused = false
	panel.hide()
	music.stop()
func show_hint():
	get_tree().paused = true
	panel.show()
	music.play()
	click_but.play()
