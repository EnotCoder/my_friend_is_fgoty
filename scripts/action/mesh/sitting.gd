extends MeshInstance3D

@onready var text: Label = $ui/text
@onready var animation_player: AnimationPlayer = $ui/AnimationPlayer
@onready var timer: Timer = $ui/timer

var is_playing: bool = false;

func _ready() -> void:
	timer.timeout.connect(timer_finish);
	
func sitting_click() -> void:
	if not is_playing:
		text.text = "It's sitting";
		animation_player.play("fade_in");
		is_playing = true;
		timer.start()
		
func timer_finish():
	animation_player.play("fade_out");
	is_playing = false;
