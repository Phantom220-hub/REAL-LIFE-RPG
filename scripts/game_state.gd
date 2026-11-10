extends Node

signal state_changed

const SAVE_PATH := "user://player_progress.cfg"
const XP_PER_LEVEL := 100
const DAILY_XP_CAP := 25

const ITEMS := {
	"focus_charm": {"name": "Кристалл фокуса", "type": "focus", "attack": 2, "defense": 0, "price": 0},
	"sun_core": {"name": "Солнечное ядро", "type": "focus", "attack": 5, "defense": 0, "price": 35},
	"travel_cloak": {"name": "Плащ путешественника", "type": "armor", "attack": 0, "defense": 1, "price": 0},
	"guardian_vest": {"name": "Жилет стража", "type": "armor", "attack": 0, "defense": 3, "price": 30},
	"potion": {"name": "Зелье лечения", "type": "consumable", "heal": 25, "price": 12}
}

const LOCATIONS := {
	"village": {"name": "Тихая деревня", "description": "Безопасное место, где путешественники отдыхают и готовятся к дороге.", "level": 1},
	"forest": {"name": "Сумрачный лес", "description": "Лесная тропа, где встречаются первые стражи.", "level": 2},
	"marsh": {"name": "Затопленные руины", "description": "Старые руины, скрытые туманом и болотной водой.", "level": 3},
	"tower": {"name": "Башня древних", "description": "Последнее испытание хранителя башни.", "level": 5}
}

const ACHIEVEMENTS := {
	"first_activity": {"name": "Первые шаги", "description": "Записать первую активность."},
	"first_win": {"name": "Первый успех", "description": "Победить первого противника."},
	"explorer": {"name": "Следопыт", "description": "Посетить три разные локации."},
	"boss": {"name": "Хранитель побеждён", "description": "Победить древнего стража."},
	"level_five": {"name": "Опытный путник", "description": "Достичь пятого уровня."},
	"rest_three": {"name": "Мастер восстановления", "description": "Выбрать отдых три раза в разные дни."}
}

const ENEMIES := {
	"scout": {"name": "Зомби-разведчик", "health": 24, "attack": 4, "coins": 8, "xp": 12, "level": 1},
	"guard": {"name": "Каменный страж", "health": 42, "attack": 7, "coins": 15, "xp": 22, "level": 2},
	"brute": {"name": "Болотный громила", "health": 65, "attack": 10, "coins": 25, "xp": 35, "level": 3},
	"ancient_guardian": {"name": "Древний страж — БОСС", "health": 110, "attack": 12, "coins": 60, "xp": 70, "level": 5}
}

var player_name: String = "Путник"
var level: int = 1
var xp: int = 0
var total_reps: int = 0
var coins: int = 0
var defeated_enemies: int = 0
var bosses_defeated: int = 0
var rest_days_total: int = 0
var visited_locations: Array = ["village"]
var current_location: String = "village"
var claimed_achievements: Dictionary = {}
var total_workout_sessions: int = 0
var daily_xp: int = 0
var daily_reps: int = 0
var daily_date: String = ""
var daily_choice_claimed: bool = false
var daily_choice_text: String = "Ещё не выбрано"
var inventory: Dictionary = {"focus_charm": 1, "travel_cloak": 1, "potion": 2}
var equipped_focus: String = "focus_charm"
var equipped_armor: String = "travel_cloak"
var enemy_id: String = ""
var enemy_health: int = 0
var player_health: int = 85
var battle_active: bool = false
var last_message: String = "Добро пожаловать!"

func _ready() -> void:
	load_progress()
	_refresh_day()

func attack_power() -> int:
	var focus_bonus: int = int(ITEMS.get(equipped_focus, {}).get("attack", 0))
	return 5 + level + focus_bonus

func defense_power() -> int:
	var armor_bonus: int = int(ITEMS.get(equipped_armor, {}).get("defense", 0))
	return 1 + int(level / 3) + armor_bonus

func max_health() -> int:
	return 80 + level * 5

func xp_to_next_level() -> int:
	return maxi(0, XP_PER_LEVEL - xp)

func add_workout_reps(reps: int) -> int:
	_refresh_day()
	var safe_reps: int = clampi(reps, 1, 100)
	total_reps += safe_reps
	daily_reps += safe_reps
	total_workout_sessions += 1
	var reward: int = mini(safe_reps, DAILY_XP_CAP - daily_xp)
	reward = maxi(0, reward)
	daily_xp += reward
	_add_xp(reward)
	last_message = "Записано %d повторений. Получено %d XP сегодня." % [safe_reps, reward]
	save_progress()
	state_changed.emit()
	return reward

func claim_daily_choice(is_rest_day: bool) -> bool:
	_refresh_day()
	if daily_choice_claimed:
		return false
	daily_choice_claimed = true
	daily_choice_text = "День отдыха" if is_rest_day else "Активный день"
	if is_rest_day:
		rest_days_total += 1
	coins += 5
	last_message = "Ежедневный выбор отмечен: %s. +5 монет." % daily_choice_text
	save_progress()
	state_changed.emit()
	return true

func start_battle(id: String) -> bool:
	if not ENEMIES.has(id):
		return false
	if level < int(ENEMIES[id]["level"]):
		last_message = "Для этой встречи нужен уровень %d." % ENEMIES[id]["level"]
		return false
	if battle_active:
		return false
	enemy_id = id
	enemy_health = int(ENEMIES[id]["health"])
	player_health = mini(player_health, max_health())
	battle_active = true
	last_message = "Начался бой: %s." % ENEMIES[id]["name"]
	state_changed.emit()
	return true

func player_attack() -> void:
	if not battle_active:
		return
	var damage: int = attack_power()
	enemy_health = maxi(0, enemy_health - damage)
	if enemy_health <= 0:
		_finish_battle()
	else:
		_enemy_turn()
	save_progress()
	state_changed.emit()

func _enemy_turn() -> void:
	var enemy: Dictionary = ENEMIES[enemy_id]
	var damage: int = maxi(1, int(enemy["attack"]) - defense_power())
	player_health = maxi(0, player_health - damage)
	if player_health <= 0:
		battle_active = false
		last_message = "Герой устал и отступил. Восстановись и попробуй позже."
	else:
		last_message = "Ты нанёс удар. Враг ответил на %d урона." % damage

func _finish_battle() -> void:
	var enemy: Dictionary = ENEMIES[enemy_id]
	coins += int(enemy["coins"])
	defeated_enemies += 1
	if enemy_id == "ancient_guardian":
		bosses_defeated += 1
	_add_xp(int(enemy["xp"]))
	battle_active = false
	last_message = "Победа над %s! +%d монет и %d XP." % [enemy["name"], enemy["coins"], enemy["xp"]]

func use_potion() -> bool:
	if int(inventory.get("potion", 0)) <= 0 or player_health >= max_health():
		return false
	inventory["potion"] = int(inventory["potion"]) - 1
	player_health = mini(max_health(), player_health + int(ITEMS["potion"]["heal"]))
	last_message = "Зелье использовано. Здоровье восстановлено."
	save_progress()
	state_changed.emit()
	return true

func buy_item(id: String) -> bool:
	if not ITEMS.has(id):
		return false
	var item: Dictionary = ITEMS[id]
	var price: int = int(item["price"])
	if price <= 0 or coins < price or item["type"] == "consumable":
		return false
	coins -= price
	inventory[id] = int(inventory.get(id, 0)) + 1
	last_message = "Куплено: %s." % item["name"]
	save_progress()
	state_changed.emit()
	return true

func equip_item(id: String) -> bool:
	if not ITEMS.has(id) or int(inventory.get(id, 0)) <= 0:
		return false
	var kind: String = str(ITEMS[id]["type"])
	if kind == "focus":
		equipped_focus = id
	elif kind == "armor":
		equipped_armor = id
	else:
		return false
	last_message = "Экипировано: %s." % ITEMS[id]["name"]
	save_progress()
	state_changed.emit()
	return true

func _add_xp(amount: int) -> void:
	xp += maxi(0, amount)
	while xp >= XP_PER_LEVEL:
		xp -= XP_PER_LEVEL
		level += 1
		player_health = max_health()

func refresh_daily_state() -> void:
	var previous_date: String = daily_date
	_refresh_day()
	if daily_date != previous_date:
		save_progress()
		state_changed.emit()

func _refresh_day() -> void:
	var today: String = Time.get_date_string_from_system()
	if daily_date != today:
		daily_date = today
		daily_xp = 0
		daily_reps = 0
		daily_choice_claimed = false
		daily_choice_text = "Ещё не выбрано"


func travel_to_location(id: String) -> bool:
	if not LOCATIONS.has(id):
		return false
	if level < int(LOCATIONS[id]["level"]):
		last_message = "Для этой локации нужен уровень %d." % LOCATIONS[id]["level"]
		return false
	current_location = id
	if not visited_locations.has(id):
		visited_locations.append(id)
	last_message = "Ты прибыл: %s." % LOCATIONS[id]["name"]
	save_progress()
	state_changed.emit()
	return true

func is_achievement_unlocked(id: String) -> bool:
	match id:
		"first_activity": return total_workout_sessions >= 1
		"first_win": return defeated_enemies >= 1
		"explorer": return visited_locations.size() >= 3
		"boss": return bosses_defeated >= 1
		"level_five": return level >= 5
		"rest_three": return rest_days_total >= 3
	return false

func claim_achievement(id: String) -> bool:
	if not ACHIEVEMENTS.has(id) or not is_achievement_unlocked(id):
		return false
	if bool(claimed_achievements.get(id, false)):
		return false
	claimed_achievements[id] = true
	coins += 10
	last_message = "Достижение получено: %s. +10 монет." % ACHIEVEMENTS[id]["name"]
	save_progress()
	state_changed.emit()
	return true

func save_progress() -> void:
	var config := ConfigFile.new()
	config.set_value("player", "name", player_name)
	config.set_value("player", "level", level)
	config.set_value("player", "xp", xp)
	config.set_value("player", "total_reps", total_reps)
	config.set_value("player", "coins", coins)
	config.set_value("player", "defeated_enemies", defeated_enemies)
	config.set_value("player", "bosses_defeated", bosses_defeated)
	config.set_value("player", "rest_days_total", rest_days_total)
	config.set_value("world", "visited_locations", visited_locations)
	config.set_value("world", "current_location", current_location)
	config.set_value("achievements", "claimed", claimed_achievements)
	config.set_value("player", "total_workout_sessions", total_workout_sessions)
	config.set_value("player", "daily_xp", daily_xp)
	config.set_value("player", "daily_reps", daily_reps)
	config.set_value("player", "daily_date", daily_date)
	config.set_value("daily", "choice_claimed", daily_choice_claimed)
	config.set_value("daily", "choice_text", daily_choice_text)
	config.set_value("inventory", "items", inventory)
	config.set_value("equipment", "focus", equipped_focus)
	config.set_value("equipment", "armor", equipped_armor)
	config.set_value("player", "player_health", player_health)
	config.save(SAVE_PATH)

func load_progress() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	player_name = str(config.get_value("player", "name", player_name))
	level = maxi(1, int(config.get_value("player", "level", 1)))
	xp = clampi(int(config.get_value("player", "xp", 0)), 0, XP_PER_LEVEL - 1)
	total_reps = maxi(0, int(config.get_value("player", "total_reps", 0)))
	coins = maxi(0, int(config.get_value("player", "coins", 0)))
	defeated_enemies = maxi(0, int(config.get_value("player", "defeated_enemies", 0)))
	bosses_defeated = maxi(0, int(config.get_value("player", "bosses_defeated", 0)))
	rest_days_total = maxi(0, int(config.get_value("player", "rest_days_total", 0)))
	visited_locations = config.get_value("world", "visited_locations", visited_locations)
	current_location = str(config.get_value("world", "current_location", current_location))
	claimed_achievements = config.get_value("achievements", "claimed", claimed_achievements)
	total_workout_sessions = maxi(0, int(config.get_value("player", "total_workout_sessions", 0)))
	daily_xp = clampi(int(config.get_value("player", "daily_xp", 0)), 0, DAILY_XP_CAP)
	daily_reps = maxi(0, int(config.get_value("player", "daily_reps", 0)))
	daily_date = str(config.get_value("player", "daily_date", ""))
	daily_choice_claimed = bool(config.get_value("daily", "choice_claimed", false))
	daily_choice_text = str(config.get_value("daily", "choice_text", "Ещё не выбрано"))
	inventory = config.get_value("inventory", "items", inventory)
	equipped_focus = str(config.get_value("equipment", "focus", equipped_focus))
	equipped_armor = str(config.get_value("equipment", "armor", equipped_armor))
	player_health = clampi(int(config.get_value("player", "player_health", max_health())), 0, max_health())
	_refresh_day()
