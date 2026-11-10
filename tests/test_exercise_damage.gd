extends SceneTree

func _initialize() -> void:
	var state = preload("res://scripts/game_state.gd").new()
	root.add_child(state)
	assert(state.start_battle("scout"), "The first encounter should be available at level 1 in the village.")
	var before: int = state.enemy_health
	var applied: int = state.apply_exercise_damage(1)
	assert(applied == 1, "One confirmed repetition should map to one point of game damage.")
	assert(state.enemy_health == before - 1, "Enemy HP should decrease by exactly one.")
	state.battle_active = false
	assert(state.apply_exercise_damage(5) == 0, "Exercise damage must not apply outside an active encounter.")
	print("Exercise damage integration tests passed.")
	quit()
