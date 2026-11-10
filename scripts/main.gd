extends Control

const GameStateScript = preload("res://scripts/game_state.gd")
const CharacterPortraitScript = preload("res://scripts/character_portrait.gd")

var game_state
var page_box: VBoxContainer
var level_label: Label
var status_label: Label
var reps_input: SpinBox

func _ready() -> void:
	game_state = GameStateScript.new()
	add_child(game_state)
	game_state.state_changed.connect(_refresh_header)
	_build_shell()
	_show_page("home")
	_refresh_header()

func _build_shell() -> void:
	var background := ColorRect.new()
	background.color = Color("#0b1220")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var layout := HBoxContainer.new()
	layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layout.offset_left = 18
	layout.offset_top = 16
	layout.offset_right = -18
	layout.offset_bottom = -16
	layout.add_theme_constant_override("separation", 14)
	add_child(layout)

	var sidebar := PanelContainer.new()
	sidebar.custom_minimum_size.x = 205
	var side_style := StyleBoxFlat.new()
	side_style.bg_color = Color("#151f33")
	side_style.set_corner_radius_all(16)
	sidebar.add_theme_stylebox_override("panel", side_style)
	layout.add_child(sidebar)
	var nav := VBoxContainer.new()
	nav.add_theme_constant_override("separation", 10)
	nav.add_theme_constant_override("margin_left", 12)
	nav.add_theme_constant_override("margin_right", 12)
	nav.add_theme_constant_override("margin_top", 16)
	sidebar.add_child(nav)
	var logo := _label("REAL LIFE\nRPG", 26, "#f2c66d")
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nav.add_child(logo)
	var tagline := _label("ТВОЁ ПРИКЛЮЧЕНИЕ", 10, "#9aabc4")
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nav.add_child(tagline)
	nav.add_child(HSeparator.new())
	_add_nav_button(nav, "⌂   Главная", "home")
	_add_nav_button(nav, "♙   Персонаж", "character")
	_add_nav_button(nav, "✦   Тренировка", "training")
	_add_nav_button(nav, "⚔   Приключение", "adventure")
	_add_nav_button(nav, "▣   Инвентарь", "inventory")
	_add_nav_button(nav, "✧   Задания", "daily")
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	nav.add_child(spacer)
	level_label = _label("УРОВЕНЬ 1", 17, "#75d5c8")
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nav.add_child(level_label)
	var offline := _label("●  ОФЛАЙН", 12, "#75d5c8")
	offline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nav.add_child(offline)

	var main_column := VBoxContainer.new()
	main_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_column.add_theme_constant_override("separation", 10)
	layout.add_child(main_column)
	var top := HBoxContainer.new()
	main_column.add_child(top)
	var heading := _label("МИР ПУТЕШЕСТВЕННИКА", 18, "#d9e3f2")
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(heading)
	top.add_child(_label("ПРОТОТИП 0.3", 11, "#63738d"))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_column.add_child(scroll)
	page_box = VBoxContainer.new()
	page_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_box.add_theme_constant_override("separation", 12)
	scroll.add_child(page_box)
	status_label = _label("Добро пожаловать!", 13, "#75d5c8")
	main_column.add_child(status_label)

func _add_nav_button(parent: VBoxContainer, caption: String, page: String) -> void:
	var button := _button(caption, "#263b59")
	button.pressed.connect(_show_page.bind(page))
	parent.add_child(button)

func _show_page(page: String) -> void:
	for child in page_box.get_children():
		page_box.remove_child(child)
		child.queue_free()
	match page:
		"home": _build_home()
		"character": _build_character()
		"training": _build_training()
		"adventure": _build_adventure()
		"inventory": _build_inventory()
		"daily": _build_daily()
		_: _build_home()

func _build_home() -> void:
	page_box.add_child(_label("Здравствуй, путешественник!", 27, "#f2c66d"))
	page_box.add_child(_label("Твои реальные привычки становятся частью игровой истории. Здесь можно развивать героя, исследовать мир и собирать экипировку.", 15, "#9aabc4"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	page_box.add_child(row)
	var hero_card := _card(row)
	hero_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hero_card.add_child(_label("ТВОЙ ГЕРОЙ", 15, "#f2c66d"))
	var portrait := Control.new()
	portrait.set_script(CharacterPortraitScript)
	portrait.custom_minimum_size = Vector2(190, 220)
	hero_card.add_child(portrait)
	hero_card.add_child(_label("%s • Уровень %d" % [game_state.player_name, game_state.level], 17, "#ffffff"))
	var stats_card := _card(row)
	stats_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats_card.add_child(_label("ТВОЙ ПРОГРЕСС", 15, "#f2c66d"))
	stats_card.add_child(_label("Опыт: %d / 100\nЗдоровье: %d / %d\nМонеты: %d\nПобеды: %d\nПовторения всего: %d" % [game_state.xp, game_state.player_health, game_state.max_health(), game_state.coins, game_state.defeated_enemies, game_state.total_reps], 16, "#d9e3f2"))
	stats_card.add_child(_button("ПЕРСОНАЖ", "#28665f", _show_page.bind("character")))
	var note := _card(page_box)
	note.add_child(_label("ВАЖНО", 15, "#f2c66d"))
	note.add_child(_label("За активность начисляется ограниченное количество XP в день. Можно выбрать и день отдыха — без штрафов. Не нужно тренироваться ради игровых наград.", 14, "#b9c9df"))

func _build_character() -> void:
	page_box.add_child(_label("ПЕРСОНАЖ", 27, "#f2c66d"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	page_box.add_child(row)
	var portrait_card := _card(row)
	portrait_card.custom_minimum_size.x = 250
	var portrait := Control.new()
	portrait.set_script(CharacterPortraitScript)
	portrait.custom_minimum_size = Vector2(220, 260)
	portrait_card.add_child(portrait)
	portrait_card.add_child(_label(game_state.player_name, 20, "#ffffff"))
	portrait_card.add_child(_label("Класс: Путешественник", 13, "#9aabc4"))
	var details := _card(row)
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_child(_label("ХАРАКТЕРИСТИКИ", 17, "#f2c66d"))
	details.add_child(_label("Уровень: %d\nОпыт: %d / 100\nЗдоровье: %d / %d\nАтака: %d\nЗащита: %d\nМонеты: %d\nПобеды: %d" % [game_state.level, game_state.xp, game_state.player_health, game_state.max_health(), game_state.attack_power(), game_state.defense_power(), game_state.coins, game_state.defeated_enemies], 15, "#d9e3f2"))
	details.add_child(_label("Оружие: %s\nБроня: %s" % [game_state.ITEMS[game_state.equipped_weapon]["name"], game_state.ITEMS[game_state.equipped_armor]["name"]], 14, "#9aabc4"))
	details.add_child(_button("ОТДОХНУТЬ И ВОССТАНОВИТЬСЯ", "#28665f", _recover))
	details.add_child(_button("ОТКРЫТЬ ИНВЕНТАРЬ", "#263b59", _show_page.bind("inventory")))

func _build_training() -> void:
	page_box.add_child(_label("ТРЕНИРОВКА", 27, "#f2c66d"))
	var card := _card(page_box)
	card.add_child(_label("ЗАПИСЬ АКТИВНОСТИ", 17, "#ffffff"))
	card.add_child(_label("Введи фактически выполненные повторения. Это временный ручной ввод: камера ещё не распознаёт движения.", 14, "#9aabc4"))
	reps_input = SpinBox.new()
	reps_input.min_value = 1
	reps_input.max_value = 100
	reps_input.value = 5
	reps_input.step = 1
	reps_input.custom_minimum_size = Vector2(170, 44)
	card.add_child(reps_input)
	card.add_child(_button("СОХРАНИТЬ РЕЗУЛЬТАТ", "#28665f", _on_workout_pressed))
	card.add_child(_label("Сегодня записано: %d повторений\nXP за сегодня: %d / %d\nСессий всего: %d" % [game_state.daily_reps, game_state.daily_xp, game_state.DAILY_XP_CAP, game_state.total_workout_sessions], 14, "#75d5c8"))
	card.add_child(_label("Игровой опыт ограничен дневным пределом. Отдых не снижает уровень и не сбрасывает прогресс.", 13, "#9aabc4"))

func _build_adventure() -> void:
	page_box.add_child(_label("ПРИКЛЮЧЕНИЕ", 27, "#f2c66d"))
	if game_state.battle_active:
		var battle := _card(page_box)
		var enemy: Dictionary = game_state.ENEMIES[game_state.enemy_id]
		battle.add_child(_label("БОЙ: %s" % enemy["name"], 20, "#f2c66d"))
		battle.add_child(_label("Здоровье врага: %d / %d\nТвоё здоровье: %d / %d" % [game_state.enemy_health, enemy["health"], game_state.player_health, game_state.max_health()], 16, "#d9e3f2"))
		battle.add_child(_button("АТАКОВАТЬ", "#75433c", _player_attack))
		battle.add_child(_button("ИСПОЛЬЗОВАТЬ ЗЕЛЬЕ (%d)" % int(game_state.inventory.get("potion", 0)), "#28665f", _use_potion))
	else:
		page_box.add_child(_label("Выбери противника. Победа зависит от характеристик и экипировки героя.", 14, "#9aabc4"))
		for id in ["scout", "guard", "brute"]:
			var enemy: Dictionary = game_state.ENEMIES[id]
			var card := _card(page_box)
			card.add_child(_label(str(enemy["name"]), 18, "#ffffff"))
			card.add_child(_label("Здоровье: %d • Атака: %d • Награда: %d монет, %d XP" % [enemy["health"], enemy["attack"], enemy["coins"], enemy["xp"]], 14, "#9aabc4"))
			var button := _button("НАЧАТЬ БОЙ", "#75433c")
			button.pressed.connect(_start_battle.bind(id))
			card.add_child(button)
	var tip := _card(page_box)
	tip.add_child(_label("СОВЕТ", 15, "#f2c66d"))
	tip.add_child(_label("Если здоровье закончилось, герой отступает. Используй зелье или восстановись отдыхом. Бои — отдельная игровая механика и не требуют физических упражнений.", 13, "#9aabc4"))

func _build_inventory() -> void:
	page_box.add_child(_label("ИНВЕНТАРЬ И МАГАЗИН", 27, "#f2c66d"))
	var equipped := _card(page_box)
	equipped.add_child(_label("СЕЙЧАС ЭКИПИРОВАНО", 16, "#f2c66d"))
	equipped.add_child(_label("Оружие: %s (+%d атаки)\nБроня: %s (+%d защиты)\nЗелья: %d" % [game_state.ITEMS[game_state.equipped_weapon]["name"], game_state.ITEMS[game_state.equipped_weapon]["attack"], game_state.ITEMS[game_state.equipped_armor]["name"], game_state.ITEMS[game_state.equipped_armor]["defense"], int(game_state.inventory.get("potion", 0))], 15, "#d9e3f2"))
	for id in ["wood_sword", "iron_sword", "cloth_armor", "leather_armor"]:
		var item: Dictionary = game_state.ITEMS[id]
		var count: int = int(game_state.inventory.get(id, 0))
		var card := _card(page_box)
		card.add_child(_label("%s • в наличии: %d" % [item["name"], count], 16, "#ffffff"))
		card.add_child(_label("Атака +%d • Защита +%d • Цена: %d монет" % [item["attack"], item["defense"], item["price"]], 13, "#9aabc4"))
		if count > 0:
			var equip_button := _button("ЭКИПИРОВАТЬ", "#28665f")
			equip_button.pressed.connect(_equip_item.bind(id))
			card.add_child(equip_button)
		elif int(item["price"]) > 0:
			var buy_button := _button("КУПИТЬ", "#263b59")
			buy_button.pressed.connect(_buy_item.bind(id))
			card.add_child(buy_button)
	var potion_card := _card(page_box)
	potion_card.add_child(_label("ЗЕЛЬЕ ЛЕЧЕНИЯ • В наличии: %d" % int(game_state.inventory.get("potion", 0)), 15, "#ffffff"))
	potion_card.add_child(_label("Восстанавливает 25 HP. Цена: 12 монет.", 13, "#9aabc4"))
	potion_card.add_child(_button("КУПИТЬ ЗЕЛЬЕ", "#263b59", _buy_potion))

func _build_daily() -> void:
	page_box.add_child(_label("ЕЖЕДНЕВНЫЙ ВЫБОР", 27, "#f2c66d"))
	var card := _card(page_box)
	card.add_child(_label("Сегодня: %s" % game_state.daily_date, 16, "#ffffff"))
	card.add_child(_label("Выбери один вариант на день: отметить активность или выбрать отдых. Оба варианта дают одинаковую небольшую награду. Нет штрафов за пропуск.", 14, "#9aabc4"))
	card.add_child(_label("Текущий выбор: %s" % game_state.daily_choice_text, 15, "#75d5c8"))
	var activity := _button("ОТМЕТИТЬ АКТИВНЫЙ ДЕНЬ (+5 МОНЕТ)", "#28665f", _claim_activity)
	activity.disabled = game_state.daily_choice_claimed
	card.add_child(activity)
	var rest := _button("ВЫБРАТЬ ДЕНЬ ОТДЫХА (+5 МОНЕТ)", "#263b59", _claim_rest)
	rest.disabled = game_state.daily_choice_claimed
	card.add_child(rest)
	var xp_card := _card(page_box)
	xp_card.add_child(_label("БЕЗОПАСНЫЙ ПРОГРЕСС", 15, "#f2c66d"))
	xp_card.add_child(_label("За ручную запись активности можно получить не более %d XP в день. Игровой прогресс не требует ежедневных тренировок. Восстановление — полноценная часть приключения." % game_state.DAILY_XP_CAP, 14, "#b9c9df"))

func _card(parent: Node) -> VBoxContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#151f33")
	style.border_color = Color("#30435f")
	style.set_border_width_all(1)
	style.set_corner_radius_all(14)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	panel.add_child(box)
	return box

func _label(value: String, font_size: int, color: String) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(color))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func _button(caption: String, color: String, callback: Callable = Callable()) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(0, 43)
	button.add_theme_font_size_override("font_size", 13)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(color)
	normal.set_corner_radius_all(9)
	normal.content_margin_top = 7
	normal.content_margin_bottom = 7
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate()
	hover.bg_color = Color(color).lightened(0.12)
	button.add_theme_stylebox_override("hover", hover)
	if callback.is_valid():
		button.pressed.connect(callback)
	return button

func _on_workout_pressed() -> void:
	if reps_input == null:
		return
	var reward: int = game_state.add_workout_reps(int(reps_input.value))
	status_label.text = game_state.last_message
	_show_page("training")

func _start_battle(id: String) -> void:
	game_state.start_battle(id)
	status_label.text = game_state.last_message
	_show_page("adventure")

func _player_attack() -> void:
	game_state.player_attack()
	status_label.text = game_state.last_message
	_show_page("adventure")

func _use_potion() -> void:
	if game_state.use_potion():
		status_label.text = game_state.last_message
	else:
		status_label.text = "Зелье нельзя использовать сейчас."
	_show_page("adventure")

func _equip_item(id: String) -> void:
	game_state.equip_item(id)
	status_label.text = game_state.last_message
	_show_page("inventory")

func _buy_item(id: String) -> void:
	if not game_state.buy_item(id):
		status_label.text = "Недостаточно монет."
	else:
		status_label.text = game_state.last_message
	_show_page("inventory")

func _buy_potion() -> void:
	if game_state.coins < 12:
		status_label.text = "Недостаточно монет."
	else:
	game_state.coins -= 12
	game_state.inventory["potion"] = int(game_state.inventory.get("potion", 0)) + 1
	game_state.last_message = "Зелье куплено."
	game_state.save_progress()
	game_state.state_changed.emit()
	status_label.text = game_state.last_message
	_show_page("inventory")

func _claim_activity() -> void:
	if game_state.claim_daily_choice(false):
		status_label.text = game_state.last_message
	else:
		status_label.text = "Сегодня выбор уже сделан."
	_show_page("daily")

func _claim_rest() -> void:
	if game_state.claim_daily_choice(true):
		game_state.player_health = game_state.max_health()
		game_state.save_progress()
		status_label.text = game_state.last_message + " Здоровье восстановлено."
	else:
		status_label.text = "Сегодня выбор уже сделан."
	_show_page("daily")

func _recover() -> void:
	if game_state.battle_active:
		status_label.text = "Сначала заверши бой или отступи."
	else:
		game_state.player_health = game_state.max_health()
		game_state.last_message = "Герой отдохнул и восстановил здоровье."
		game_state.save_progress()
		game_state.state_changed.emit()
		status_label.text = game_state.last_message
	_show_page("character")

func _refresh_header() -> void:
	if level_label != null:
		level_label.text = "УРОВЕНЬ %d" % game_state.level
	if status_label != null and game_state.last_message != "":
		status_label.text = game_state.last_message
