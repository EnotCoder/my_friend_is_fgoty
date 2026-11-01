extends Area3D

@export var texture_obj: Texture
@export var mac: MeshInstance3D
@export var shadow: bool = true

const AMPLITUDE: float = 0.2
const SPEED_SIN: float = 2.0
const SPEED_ROT: float = 1.8
const SPEED_SCALE_CODE: float = 5.0
const SPEED_SCALE_SHADOW: float = 4.0

@onready var sprite_code: Sprite3D = $sprite_code
@onready var grass_shadow_cell: MeshInstance3D = $GrassShadowCell
@onready var ui: Control = $ui/ui
@onready var code: TextureRect = $ui/ui/code
@onready var part: CPUParticles3D = $part

var is_get: bool = false

func explode() -> void:
	part.restart()
	part.emitting = true

var time: float = 0.0
var start_y: float = 0.0
var del_scale: Vector3 = Vector3.ZERO

var scale_tween: Tween

func _process(delta: float) -> void:
	time += delta
	sprite_code.position.y = start_y + sin(time * SPEED_SIN) * AMPLITUDE
	sprite_code.rotation.y += delta * SPEED_ROT

	if sprite_code.scale != del_scale:
		sprite_code.scale = lerp(sprite_code.scale, del_scale, 
			delta * SPEED_SCALE_CODE)
		grass_shadow_cell.scale = lerp(grass_shadow_cell.scale, 
			del_scale, delta * SPEED_SCALE_SHADOW)
		

func _ready() -> void:
	code.texture = texture_obj
	body_entered.connect(on_player_entered)
	start_y = sprite_code.position.y
	del_scale = sprite_code.scale
	
	if shadow:
		grass_shadow_cell.show()

	_spawn_animation()


## Появление код-объекта с пружинкой.
func _spawn_animation() -> void:
	var target := scale
	scale = target * 0.01

	scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", target, 0.4) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	
func on_player_entered(body: Node3D) -> void:
	if body is Player:
		del()
		ui.start()


func del():
	set_deferred("monitoring", false)
	del_scale = Vector3.ZERO

	if scale_tween and scale_tween.is_valid():
		scale_tween.kill()

	# Закручиваем и уменьшаем объект при сборе.
	scale_tween = create_tween().set_parallel(true)
	scale_tween.tween_property(self, "scale", scale * 0.01, 0.35) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	scale_tween.tween_property(self, "rotation:y", rotation.y + TAU, 0.35) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

