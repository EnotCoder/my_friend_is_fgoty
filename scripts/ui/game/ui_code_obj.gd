extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var use: Button = $use
@onready var delete: Button = $delete
@onready var mac = $"../.."
@onready var parent_parent = $"../.."
@onready var code: TextureRect = $code
@onready var click_but: AudioStreamPlayer = $"../../sounds/click_but"


func _ready() -> void:
	use.pressed.connect(pressed_use)
	delete.pressed.connect(pressed_delete)

	UiAnim.hover_scale(use, 1.05)
	UiAnim.hover_scale(delete, 1.05)


func start() -> void:
	get_tree().paused = true
	animation_player.play("fade_in")


func pressed_use() -> void:
	get_tree().paused = false
	animation_player.play("fade_out")
	mac.mac.add_code(code.texture)
	parent_parent.explode()
	click_but.play()

	mac.is_get = true


func pressed_delete() -> void:
	get_tree().paused = false
	animation_player.play("fade_out")
	click_but.play()
