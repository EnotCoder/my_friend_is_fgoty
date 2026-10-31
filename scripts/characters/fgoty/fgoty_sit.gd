extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.play("fgoty_sit")

@onready var hint_label: Control = $hint_label

@onready var friend: Sprite3D = $friend
var friend_modulete: Color = Color(1.0, 1.0, 1.0, 1.0)
const SPEED_MODULATE: float = 5.0

func fgoty_click():
	hint_label.object_click("Fgoty likes Frglib. 
		I have to solve his riddle in this library")
	
	friend_modulete = Color(1.0, 1.0, 1.0, 0.0)
	
func _process(delta: float) -> void:
	if friend_modulete != friend.modulate:
		friend.modulate = lerp(friend.modulate, 
			friend_modulete, delta * SPEED_MODULATE)
