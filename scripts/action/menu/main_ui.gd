extends Control

@onready var version: Label = $version
@onready var date: Label = $date


func _ready() -> void:
	UiAnim.slide_in(version, Vector2(-40.0, 0.0), 0.5, 0.1)
	UiAnim.slide_in(date, Vector2(40.0, 0.0), 0.5, 0.15)
