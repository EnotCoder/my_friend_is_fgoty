extends CharacterBody3D

@export var player: Node3D

@export var move_speed: float = 2.0
@export var stop_distance: float = 1.2
@export var gravity: float = 9.8

# Включи, если модель смотрит на игрока спиной.
@export var model_front_is_positive_z: bool = false


func _physics_process(delta: float) -> void:
	# Гравитация работает даже без назначенного игрока.
	if not is_on_floor():
		velocity.y -= gravity * delta

	velocity.x = 0.0
	velocity.z = 0.0

	if is_instance_valid(player):
		var offset = player.global_position - global_position

		# Не учитываем разницу высоты.
		offset.y = 0.0

		var distance = offset.length()

		# Поворачиваемся даже когда уже остановились рядом.
		# При совпадении позиций направление не определено.
		if not offset.is_zero_approx():
			var target = global_position + offset

			look_at(target, Vector3.UP, true)

		if distance > stop_distance:
			var direction = offset / distance

			var speed = minf(
				move_speed,
				(distance - stop_distance) / delta
			)

			velocity.x = direction.x * speed
			velocity.z = direction.z * speed

	move_and_slide()
