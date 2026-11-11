extends MeshInstance3D

@export var speed: float = 2.0
@export var amplitude: float = 0.2

var start_y: float = 0.0
var time: float = 0.0

func _ready() -> void:
	start_y = position.y

func _process(dt: float) -> void:
	time += dt
	position.y = start_y + sin(time * speed) * amplitude
