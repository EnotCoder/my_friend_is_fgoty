extends Sprite3D

const AMPLITUDE: float = 0.2
const SPEED: float = 2.0
@export var start_y: float = 0.0
var time: float = 0.0

func _ready() -> void:
	position.y = start_y

func _process(dt: float) -> void:
	time += dt
	position.y = start_y + sin(time * SPEED) * AMPLITUDE
