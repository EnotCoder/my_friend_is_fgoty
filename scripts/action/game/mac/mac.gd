extends MeshInstance3D

## Массив текстур, которые считаются правильным решением уровня.
@export var finish_code: Array[Texture2D]

@onready var ui: Control = $ui

## Хранилище текстур кода, собранных игроком.
var code_inventory: Array[Texture2D] = []


func _ready() -> void:
	ui.hide()


## Вызывается при взаимодействии с объектом компьютера.
func on_mac_click() -> void:
	get_tree().paused = true
	ui.show()


## Добавляет новую карточку кода в инвентарь компьютера.
func add_code(texture: Texture2D) -> void:
	code_inventory.append(texture)
	if ui.has_method("load_new_code"):
		ui.load_new_code(texture)

