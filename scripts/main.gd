extends Control

const GameStateScript = preload("res://scripts/game_state.gd")
const CharacterPortraitScript = preload("res://scripts/character_portrait.gd")

var game_state: Node
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
	layout.offset_left = 22
	layout.offset_top = 18
	layout.offset_right = -22
	layout.offset_bottom = -18
	layout.add_theme_constant_override("separation", 18)
	add_child(layout)

	var sidebar := PanelContainer.new()
	sidebar.custom_minimum_size.x = 220
	var side_style := StyleBoxFlat.new()
	side_style.bg_color = Color("#151f33")
	side_style.set_corner_radius_all(16)
	sidebar.add_theme_stylebox_override("panel", side_style)
	layout.add_child(sidebar)

	var nav := VBoxContainer.new()
	nav.add_theme_constant_override("separation", 12)
	nav.add_theme_constant_override("margin_left", 14)
	nav.add_theme_constant_override("margin_right", 14)
	nav.add_theme_constant_override("margin_top", 18)
	sidebar.add_child(nav)

	var logo := _label("REAL LIFE\nRPG", 27, "#f2c66d")
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nav.add_child(logo)
	var tagline := _label("ТВОЁ ПРИКЛЮЧЕНИЕ", 11, "#9aabc4")
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nav.add_child(tagline)
	var divider := HSeparator.new()
	nav.add_child(divider)
	_add_nav_button(nav, "⌂   Главная", "home")
	_add_nav_button(nav, "♙   Персонаж", "character")
	_add_nav_button(nav, "✦   Тренировка", "training")
	_add_nav_button(nav, "⚔   Приключение", "adventure")
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	nav.add_child(spacer)
	level_label = _label("УРОВЕНЬ 1", 18, "#75d5c8")
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nav.add_child(level_label)
	var offline := _label("●  ОФЛАЙН", 12, "#75d5c8")
	offline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nav.add_child(offline)

	var main_column := VBoxContainer.new()
	main_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_column.add_theme_constant_override("separation", 12)
	layout.add_child(main_column)

	var top := HBoxContainer.new()
	main_column.add_child(top)
	var heading := _label("МИР ПУТЕШЕСТВЕННИКА", 19, "#d9e3f2")
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(heading)
	var version := _label("ПРОТОТИП 0.2", 12, "#63738d")
	top.add_child(version)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_column.add_child(scroll)
	page_box = VBoxContainer.new()
	page_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_box.add_theme_constant_override("separation", 14)
	scroll.add_child(page_box)

	status_label = _label("Добро пожаловать!", 14, "#75d5c8")
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
		"home":
			_build_home()
		"character":
			_build_character()
		"training":
			_build_training()
		"adventure":
			_build_adventure()
		_:
			_build_home()

func _build_home() -> void:
	page_box.add_child(_label("Здравствуй, путешественник!", 28, "#f2c66d"))
	page_box.add_child(_label("Каждая маленькая победа в реальной жизни становится частью твоей истории.", 16, "#9aabc4"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	page_box.add_child(row)
	var hero_card := _card(row)
	hero_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hero_card.add_child(_label("ТВОЙ ГЕРОЙ", 16, "#f2c66d"))
	var portrait := Control.new()
	portrait.set_script(CharacterPortraitScript)
	portrait.custom_minimum_size = Vector2(220, 245)
	hero_card.add_child(portrait)
	hero_card.add_child(_label(game_state.player_name + " • Уровень " + str(game_state.level), 18, "#ffffff"))
	var stats_card := _card(row)
	stats_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats_card.add_child(_label("ТВОЙ ПРОГРЕСС", 16, "#f2c66d"))
	stats_card.add_child(_label("Уровень: %d\nОпыт: %d / 100\nМонеты: %d\nПобеды: %d\nВсего повторений: %d" % [game_state.level, game_state.xp, game_state.coins, game_state.defeated_enemies, game_state.total_reps], 18, "#d9e3f2"))
	stats_card.add_child(_button("ОТКРЫТЬ ПЕРСОНАЖА", "#28665f", _show_page.bind("character")))
	var hint := _card(page_box)
	hint.add_child(_label("ТВОЯ ЦЕЛЬ", 16, "#f2c66d"))
	hint.add_child(_label("Развивай героя постепенно, исследуй мир и не забывай про отдых. Камера и автоматическое распознавание упражнений пока находятся в разработке.", 15, "#b9c9df"))

func _build_character() -> void:
	page_box.add_child(_label("ПЕРСОНАЖ", 28, "#f2c66d"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 18)
	page_box.add_child(row)
	var portrait_card := _card(row)
	portrait_card.custom_minimum_size.x = 280
	var portrait := Control.new()
	portrait.set_script(CharacterPortraitScript)
	portrait.custom_minimum_size = Vector2(250, 285)
	portrait_card.add_child(portrait)
	portrait_card.add_child(_label(game_state.player_name, 22, "#ffffff"))
	portrait_card.add_child(_label("Класс: Путешественник", 14, "#9aabc4"))
	var details := _card(row)
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_child(_label("ХАРАКТЕРИСТИКИ", 18, "#f2c66d"))
	details.add_child(_label("Уровень: %d\nОпыт: %d / 100\nДо нового уровня: %d XP\nМонеты: %d\nПобеждено врагов: %d\nВыполнено повторений: %d" % [game_state.level, game_state.xp, game_state.xp_to_next_level(), game_state.coins, game_state.defeated_enemies, game_state.total_reps], 17, "#d9e3f2"))
	details.add_child(_label("Экипировка и навыки появятся в следующих версиях.", 14, "#9aabc4"))

func _build_training() -> void:
	page_box.add_child(_label("ТРЕНИРОВКА", 28, "#f2c66d"))
	var card := _card(page_box)
	card.add_child(_label("ЗАПИСЬ АКТИВНОСТИ", 18, "#ffffff"))
	card.add_child(_label("Пока введи количество выполненных повторений вручную. Это тестовая система: камера ещё не распознаёт движения.", 15, "#9aabc4"))
	reps_input = SpinBox.new()
	reps_input.min_value = 1
	reps_input.max_value = 100
	reps_input.value = 5
	reps_input.step = 1
	reps_input.custom_minimum_size = Vector2(180, 46)
	card.add_child(reps_input)
	card.add_child(_button("СОХРАНИТЬ РЕЗУЛЬТАТ", "#28665f", _on_workout_pressed))
	card.add_child(_label("Опыт начисляется за запись активности. Делай упражнения безопасно и оставляй время на восстановление.", 14, "#75d5c8"))

func _build_adventure() -> void:
	page_box.add_child(_label("ПРИКЛЮЧЕНИЕ", 28, "#f2c66d"))
	var card := _card(page_box)
	card.add_child(_label("ЗАБРОШЕННАЯ ЗАСТАВА", 20, "#ffffff"))
	card.add_child(_label("На старой дороге замечен зомби-разведчик. Это тренировочная встреча прототипа, а не полноценная боевая система.", 15, "#9aabc4"))
	card.add_child(_label("Враг: Зомби-разведчик\nОпасность: низкая\nНаграда: 5 монет", 17, "#d9e3f2"))
	card.add_child(_button("ЗАВЕРШИТЬ ТЕСТОВЫЙ БОЙ", "#75433c", _on_fight_pressed))
	var note := _card(page_box)
	note.add_child(_label("ДАЛЬШЕ ПО ПЛАНУ", 16, "#f2c66d"))
	note.add_child(_label("Карта мира, настоящие враги, боссы, анимации и сюжетные задания будут добавляться постепенно.", 15, "#9aabc4"))

func _card(parent: Node) -> VBoxContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#151f33")
	style.border_color = Color("#30435f")
	style.set_border_width_all(1)
	style.set_corner_radius_all(14)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
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
	button.custom_minimum_size = Vector2(0, 46)
	button.add_theme_font_size_override("font_size", 14)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(color)
	normal.set_corner_radius_all(9)
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
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
	var reps := int(reps_input.value)
	game_state.add_workout_reps(reps)
	status_label.text = "Записано %d повторений • +%d XP. Не забывай отдыхать." % [reps, reps]
	_show_page("training")

func _on_fight_pressed() -> void:
	if game_state.defeat_enemy():
		status_label.text = "Тестовая победа! +5 монет."
	_show_page("adventure")

func _refresh_header() -> void:
	if level_label != null:
		level_label.text = "УРОВЕНЬ %d" % game_state.level
