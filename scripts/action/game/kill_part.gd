extends Area3D

@export var sound: AudioStreamPlayer
@export var player: CharacterBody3D

func _ready() -> void:
	body_entered.connect(on_player_entered)
	
func on_player_entered(body: Node3D) -> void:
	if body is Player:
		if is_instance_valid(player):
			player.fall_part.restart()
		if is_instance_valid(sound):
			sound.play()
