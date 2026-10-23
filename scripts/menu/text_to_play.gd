extends Sprite3D

const TEXT_TO_CLICK = preload("uid://1y1y83jcvgq4");
const TEXT_TO_PLAY = preload("uid://b0p4pynsalmiu");

const AMPLITUDE: float = 0.2;
const SPEED: float = 2.0;
var start_y: float = 0.725;
var time: float = 0.0;

func _ready() -> void:
	texture = TEXT_TO_PLAY;
	position.y = start_y;

func _process(dt: float) -> void:
	time += dt;
	position.y = start_y + sin(time * SPEED) * AMPLITUDE;
	
func on_cursor_mac_entered():
	texture = TEXT_TO_CLICK;
	
func on_cursor_mac_exited():
	texture = TEXT_TO_PLAY;
