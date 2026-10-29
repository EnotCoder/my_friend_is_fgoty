extends TextureButton

@onready var panel: Control = $"..";

func _ready() -> void:
	pressed.connect(panel.show_hint);
