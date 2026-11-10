extends Node

signal state_changed

const SAVE_PATH := "user://player_progress.cfg"
const XP_PER_REP := 1
const XP_PER_LEVEL := 100

var player_name: String = "Путник"
var level: int = 1
var xp: int = 0
var total_reps: int = 0
var coins: int = 0
var defeated_enemies: int = 0

func _ready() -> void:
	load_progress()

func add_workout_reps(reps: int) -> void:
	var safe_reps: int = clampi(reps, 0, 100)
	if safe_reps <= 0:
		return
	total_reps += safe_reps
	xp += safe_reps * XP_PER_REP
	_check_level_up()
	save_progress()
	state_changed.emit()

func defeat_enemy() -> bool:
	var required_level: int = 1
	if level < required_level:
		return false
	defeated_enemies += 1
	coins += 5
	save_progress()
	state_changed.emit()
	return true

func xp_to_next_level() -> int:
	return maxi(0, XP_PER_LEVEL - xp)

func _check_level_up() -> void:
	while xp >= XP_PER_LEVEL:
		xp -= XP_PER_LEVEL
		level += 1

func save_progress() -> void:
	var config := ConfigFile.new()
	config.set_value("player", "name", player_name)
	config.set_value("player", "level", level)
	config.set_value("player", "xp", xp)
	config.set_value("player", "total_reps", total_reps)
	config.set_value("player", "coins", coins)
	config.set_value("player", "defeated_enemies", defeated_enemies)
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
