extends Control

var is_playing: bool = false;

@onready var text: Label = $text
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $timer

func _ready() -> void:
	timer.timeout.connect(timer_finish);
	
func object_click(text_hint: String) -> void:
	if not is_playing and not World.is_show_hint:
		text.text = text_hint;
		animation_player.play("fade_in");
		is_playing = true;
		World.is_show_hint = true;
		timer.start()
		
func timer_finish():
	animation_player.play("fade_out");
	is_playing = false;
	World.is_show_hint = false;
