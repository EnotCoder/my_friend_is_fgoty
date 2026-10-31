extends MeshInstance3D

enum state_book {IDLE, ROTATE_MAC, ROTATE_BACK, IDLE_MAC}
var state: state_book = state_book.IDLE

var hovered := false

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _process(_dt: float) -> void:
	var is_playing: bool = animation_player.is_playing()
	
	if not is_playing:
		if state == state_book.IDLE:
			animation_player.play("idle_rust")
		elif state == state_book.IDLE_MAC:
			pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		pass
		

func on_cursor_mac_entered():
	if hovered:
		return
		
	hovered = true
	state = state_book.IDLE_MAC
	animation_player.play("fast_rotate_mac", 0.15)
	
func on_cursor_mac_exited() -> void:
	if not hovered:
		return
	
	hovered = false
	state = state_book.IDLE
	animation_player.play("fast_rotate_back", 0.15)
	
