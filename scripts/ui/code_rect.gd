extends ColorRect

@onready var image: TextureRect = $TextureRect


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if not data is Dictionary:
		return false

	return (
		data.get("type") == "code_card"
		and data.get("texture") is Texture2D
	)


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	image.texture = data["texture"]

	# Удаляем исходную карточку только после успешного переноса.
	var source := data.get("source") as Control

	if is_instance_valid(source):
		source.queue_free()
