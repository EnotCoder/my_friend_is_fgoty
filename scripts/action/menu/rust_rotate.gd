extends MeshInstance3D

# Поворот относительно исходного положения при наведении.
@export var hover_angle_degrees: float = -90.0

# Чем больше, тем быстрее поворот к цели.
@export var rotation_speed: float = 10.0

# Покачивание без наведения.
@export var idle_amplitude_degrees: float = 5.0
@export var idle_speed: float = 2.0

var hovered: bool = false

var elapsed: float = 0.0
var base_rotation: Vector3
var current_offset: float = 0.0


func _ready() -> void:
	# Запоминаем положение, заданное в редакторе.
	base_rotation = rotation


func _process(delta: float) -> void:
	elapsed += delta

	var target_offset: float

	if hovered:
		target_offset = deg_to_rad(hover_angle_degrees)
	else:
		target_offset = (
			sin(elapsed * idle_speed)
			* deg_to_rad(idle_amplitude_degrees)
		)

	# Плавность с учётом времени между кадрами.
	var weight = 1.0 - exp(-rotation_speed * delta)

	current_offset = lerp_angle(
		current_offset,
		target_offset,
		weight
	)

	# Сохраняем исходные X и Z, меняем только угол Y.
	rotation = Vector3(
		base_rotation.x,
		base_rotation.y + current_offset,
		base_rotation.z
	)


func on_cursor_mac_entered() -> void:
	hovered = true


func on_cursor_mac_exited() -> void:
	hovered = false
