extends MeshInstance3D

## Массив текстур, которые считаются правильным решением уровня.
@export var finish_code: Array[Texture2D]

@onready var ui: Control = $ui
@onready var screen: MeshInstance3D = $mac_screen_code

## Хранилище текстур кода, собранных игроком.
var code_inventory: Array[Texture2D] = []


func _ready() -> void:
	ui.hide()


## Вызывается при взаимодействии с объектом компьютера.
func on_mac_click() -> void:
	get_tree().paused = true
	_flash_screen()

	if ui.has_method("open"):
		ui.open()
	else:
		ui.show()


## Короткая вспышка экрана при включении компьютера.
func _flash_screen() -> void:
	var material := screen.material_override as ShaderMaterial
	if material == null:
		return

	material.set_shader_parameter("brightness", 2.6)

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_method(
		func(value: float) -> void:
			material.set_shader_parameter("brightness", value),
		2.6,
		1.0,
		0.55
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


## Добавляет новую карточку кода в инвентарь компьютера.
func add_code(texture: Texture2D) -> void:
	code_inventory.append(texture)
	if ui.has_method("load_new_code"):
		ui.load_new_code(texture)

