extends Node3D

@onready var hint_label: Control = $hint_label

func rico_click():
	hint_label.object_click("Rico also likes Frglib. 
		I have to solve his riddle in this library")
