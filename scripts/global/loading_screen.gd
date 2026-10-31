extends CanvasLayer

const MIN_LOAD_TIME_MS: int = 800
const SWITCH_TIMEOUT_FRAMES: int = 30
const DOTS: PackedStringArray = ["Loading.", "Loading..", "Loading..."]
const DOT_STEP_TIME: float = 0.25

@onready var text: Label = $Control/text

var is_loading: bool = false
var dot_index: int = 0
var dot_time: float = 0.0

func _ready() -> void:
	hide()

func _process(delta: float) -> void:
	if not visible:
		return
	
	dot_time += delta
	if dot_time >= DOT_STEP_TIME:
		dot_time = fmod(dot_time, DOT_STEP_TIME)
		dot_index = (dot_index + 1) % DOTS.size()
		text.text = DOTS[dot_index]

func change_scene(scene_path: String) -> void:
	if is_loading:
		return
	
	is_loading = true
	dot_index = 0
	dot_time = 0.0
	text.text = DOTS[0]
	show()
	
	var start_ms: int = Time.get_ticks_msec()
	var packed: PackedScene = await _load_scene(scene_path, start_ms)
	var previous: Node = get_tree().current_scene
	
	if packed != null:
		get_tree().change_scene_to_packed(packed)
	else:
		get_tree().change_scene_to_file(scene_path)
	
	# Ждём, пока новая сцена станет текущей, и только потом убираем чёрный экран.
	for i in range(SWITCH_TIMEOUT_FRAMES):
		await get_tree().process_frame
		
		var current: Node = get_tree().current_scene
		if current != null and current != previous:
			break
	
	hide()
	is_loading = false

func _load_scene(scene_path: String, start_ms: int) -> PackedScene:
	var packed: PackedScene = null
	var finished: bool = false
	var use_threaded: bool = ResourceLoader.load_threaded_request(scene_path) == OK
	
	if use_threaded:
		while not finished:
			var progress: Array = []
			var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(scene_path, progress)
			
			if status == ResourceLoader.THREAD_LOAD_LOADED:
				packed = ResourceLoader.load_threaded_get(scene_path) as PackedScene
				finished = true
			elif status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				# Не загрузилось — ниже сработает обычный change_scene_to_file.
				finished = true
			else:
				await get_tree().process_frame
	
	# Экран загрузки виден минимум MIN_LOAD_TIME_MS (0.8 сек),
	# чтобы быстрая загрузка не мигала.
	while Time.get_ticks_msec() - start_ms < MIN_LOAD_TIME_MS:
		await get_tree().process_frame
	
	return packed
