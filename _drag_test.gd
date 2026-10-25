extends SceneTree

## ВРЕМЕННЫЙ тест логики drag & drop панелей Mac. Удалить после проверки.

var fails := 0

func check(cond: bool, msg: String) -> void:
	if cond:
		print("OK   - ", msg)
	else:
		fails += 1
		print("FAIL - ", msg)

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene: PackedScene = load("res://scenes/action_scene/mac.tscn")
	check(scene != null, "mac.tscn загрузился")

	var mac := scene.instantiate()
	root.add_child(mac)

	var ui: Control = mac.get_node("ui")
	var left: VBoxContainer = ui.get_node("code_rect/code_list/MarginContainer/code_list")
	var right: VBoxContainer = ui.get_node("my_code_rect/scroll/MarginContainer/code_list")

	# 1. Начальное состояние слотов.
	check(left.get_child_count() == 4, "слева 4 слота (2 пустых из сцены + 2 карточки), сейчас: %d" % left.get_child_count())
	check(right.get_child_count() == 4, "справа 4 пустых слота, сейчас: %d" % right.get_child_count())

	var left_panel: ScrollContainer = ui.get_node("code_rect/code_list")
	var right_panel: ScrollContainer = ui.get_node("my_code_rect/scroll")
	check(left_panel.get_script() != null, "скрипт панели на левом ScrollContainer")
	check(right_panel.get_script() != null, "скрипт панели на правом ScrollContainer")

	# 2. Раскладка mouse_filter.
	var slot0: TextureRect = left.get_child(0)
	check(slot0.mouse_filter == Control.MOUSE_FILTER_PASS, "слот PASS (старт drag + проходим вверх при дропе)")
	check(left.get_node("MarginContainer").mouse_filter == Control.MOUSE_FILTER_IGNORE, "MarginContainer IGNORE")
	check(left.mouse_filter == Control.MOUSE_FILTER_IGNORE, "VBox IGNORE")
	check(right_panel.mouse_filter == Control.MOUSE_FILTER_STOP, "ScrollContainer STOP (дроп + колесо)")

	# 3. Пустые слоты не тянутся, полные — тянутся.
	check(slot0._get_drag_data(Vector2.ZERO) == null, "пустой слот НЕ начинает drag")
	var card: TextureRect = left.get_child(2)
	check(card.texture != null and not card.is_empty(), "слот с карточкой непустой")
	check(card._get_drag_data(Vector2.ZERO) is Dictionary, "карточка начинает drag")

	# 4. can_drop_data обеих панелей.
	var data := {"type": "code_card", "texture": card.texture, "source": card}
	check(left_panel._can_drop_data(Vector2.ZERO, data), "левая панель принимает дроп (есть пустые)")
	check(right_panel._can_drop_data(Vector2.ZERO, data), "правая панель принимает дроп (есть пустые)")

	# 5. Дроп «слева -> направо»: карточка уезжает, источник становится пустым.
	var right_slot: TextureRect = right.get_child(0)
	check(right_panel.is_empty_slot(right_slot), "первый правый слот пуст до дропа")

	var card_tex := card.texture
	right_panel._drop_data(Vector2.ZERO, data)

	check(right_slot.texture == card_tex, "карточка встала в правый слот")
	check(card.is_empty(), "источник стал пустым слотом")
	check(left_panel._can_drop_data(Vector2.ZERO, data), "слева всё ещё есть пустые места")

	# 6. Дроп «направо -> налево»: карточка возвращается обратно.
	var back_data := {"type": "code_card", "texture": right_slot.texture, "source": right_slot}
	left_panel._drop_data(Vector2.ZERO, back_data)
	check(card.texture == card_tex, "карточка вернулась на левую панель")
	check(right_panel.is_empty_slot(right_slot), "правый слот снова пуст")

	# 7. Невалидные данные отклоняются.
	check(not left_panel._can_drop_data(Vector2.ZERO, "мусор"), "не-словарь отклонён")
	check(not left_panel._can_drop_data(Vector2.ZERO, {"type": "nope"}), "чужой тип отклонён")

	# 8. Полная панель не принимает дроп: заполняем все 4 правых слота.
	for i in right.get_child_count():
		var s: TextureRect = right.get_child(i)
		s.texture = slot0.EMPTY_TEXTURE if i % 2 == 1 else card_tex
	for i in right.get_child_count():
		var s: TextureRect = right.get_child(i)
		s.texture = card_tex if i % 2 == 0 else null
	# заняты все:
	for i in right.get_child_count():
		right.get_child(i).texture = card_tex
	check(not right_panel._can_drop_data(Vector2.ZERO, data), "полная панель НЕ принимает дроп")

	print("\n", "ВСЕ ТЕСТЫ ПРОШЛИ" if fails == 0 else "ПРОВАЛЕНО: %d" % fails)
	quit(1 if fails else 0)
