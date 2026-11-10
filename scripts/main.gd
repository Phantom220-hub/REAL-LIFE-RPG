extends Control

const GameStateScript = preload("res://scripts/game_state.gd")

var game_state: Node
var level_label: Label
var xp_label: Label
var stats_label: Label
var enemy_label: Label
var reps_input: SpinBox
var status_label: Label

func _ready() -> void:
	game_state = GameStateScript.new()
	add_child(game_state)
	game_state.state_changed.connect(_refresh)
	_build_interface()
	_refresh()

func _build_interface() -> void:
	var background := ColorRect.new()
	background.color = Color("#0b1220")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.offset_left = 28
	root.offset_top = 24
	root.offset_right = -28
	root.offset_bottom = -24
	root.add_theme_constant_override("separation", 16)
	add_child(root)

	var header := HBoxContainer.new()
	root.add_child(header)

	var title := Label.new()
	title.text = "REAL LIFE  RPG"
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color("#f2c66d"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	level_label = Label.new()
	level_label.add_theme_font_size_override("font_size", 22)
	level_label.add_theme_color_override("font_color", Color("#75d5c8"))
	header.add_child(level_label)

	var subtitle := Label.new()
	subtitle.text = "ТВОЯ РЕАЛЬНАЯ ЖИЗНЬ — ТВОЁ ПРИКЛЮЧЕНИЕ"
	subtitle.add_theme_font_size_override("font_size", 14)
	subtitle.add_theme_color_override("font_color", Color("#9aabc4"))
	root.add_child(subtitle)

	var columns := HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 18)
	root.add_child(columns)

	var left := _make_panel()
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_child(left)

	var hero_title := _make_label("ПЕРСОНАЖ", 20, "#f2c66d")
	left.get_child(0).add_child(hero_title)
	var hero := _make_label("⚔  ПУТНИК", 28, "#ffffff")
	left.get_child(0).add_child(hero)
	stats_label = _make_label("", 17, "#b9c9df")
	left.get_child(0).add_child(stats_label)
	xp_label = _make_label("", 16, "#75d5c8")
	left.get_child(0).add_child(xp_label)

	var workout_title := _make_label("ТРЕНИРОВКА", 20, "#f2c66d")
	left.get_child(0).add_child(workout_title)
	var workout_hint := _make_label("Запиши выполненные повторения. Приложение пока не проверяет их камерой.", 14, "#9aabc4")
	workout_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left.get_child(0).add_child(workout_hint)

	reps_input = SpinBox.new()
	reps_input.min_value = 1
	reps_input.max_value = 100
	reps_input.value = 5
	reps_input.step = 1
	reps_input.custom_minimum_size = Vector2(150, 44)
	left.get_child(0).add_child(reps_input)

	var workout_button := _make_button("ЗАПИСАТЬ ТРЕНИРОВКУ", "#28665f")
	workout_button.pressed.connect(_on_workout_pressed)
	left.get_child(0).add_child(workout_button)

	var right := _make_panel()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_child(right)

	right.get_child(0).add_child(_make_label("МИР И ПРИКЛЮЧЕНИЯ", 20, "#f2c66d"))
	enemy_label = _make_label("Зомби-разведчик\nУгроза: низкая\nНаграда: 5 монет", 19, "#d9e3f2")
	right.get_child(0).add_child(enemy_label)
	var enemy_button := _make_button("ВСТУПИТЬ В БОЙ", "#75433c")
	enemy_button.pressed.connect(_on_fight_pressed)
	right.get_child(0).add_child(enemy_button)

	right.get_child(0).add_child(_make_label("ПРОГРЕСС", 20, "#f2c66d"))
	var progress_hint := _make_label("Уровень растёт за накопленный опыт. Прогресс хранится на устройстве и доступен офлайн.", 14, "#9aabc4")
	progress_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right.get_child(0).add_child(progress_hint)

	status_label = _make_label("Добро пожаловать в приключение!", 15, "#75d5c8")
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(status_label)

	var footer := _make_label("ПРОТОТИП 0.1  •  ОФЛАЙН-СОХРАНЕНИЕ", 12, "#63738d")
	root.add_child(footer)

func _make_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#151f33")
	style.border_color = Color("#30435f")
	style.set_border_width_all(1)
	style.set_corner_radius_all(14)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	panel.add_theme_stylebox_override("panel", style)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)
	return panel

func _make_label(value: String, size: int, color: String) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color(color))
	return label

func _make_button(value: String, color: String) -> Button:
	var button := Button.new()
	button.text = value
	button.custom_minimum_size = Vector2(0, 48)
	button.add_theme_font_size_override("font_size", 15)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(color)
	normal.set_corner_radius_all(9)
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
	button.add_theme_stylebox_override("normal", normal)
	var hover := normal.duplicate()
	hover.bg_color = Color(color).lightened(0.12)
	button.add_theme_stylebox_override("hover", hover)
	return button

func _on_workout_pressed() -> void:
	var reps := int(reps_input.value)
	game_state.add_workout_reps(reps)
	status_label.text = "Записано: %d повторений. Получено %d XP. Не забывай отдыхать." % [reps, reps]

func _on_fight_pressed() -> void:
	game_state.defeat_enemy()
	status_label.text = "Победа! Получено 5 монет. Это учебный бой прототипа."

func _refresh() -> void:
	level_label.text = "УРОВЕНЬ %d" % game_state.level
	stats_label.text = "Опыт: %d / 100\nВсего повторений: %d\nМонеты: %d\nПобеждено врагов: %d" % [
		game_state.xp, game_state.total_reps, game_state.coins, game_state.defeated_enemies
	]
	xp_label.text = "До следующего уровня: %d XP" % game_state.xp_to_next_level()
