extends SceneTree

const Counter = preload("res://scripts/exercise_pose_counter.gd")

func _initialize() -> void:
	var counter = Counter.new()
	counter.set_exercise(Counter.Exercise.SQUAT)
	var counted := [0]
	counter.repetition_counted.connect(func(total: int): counted[0] = total)
	var upright := _pose(180.0)
	var lowered := _pose(90.0)
	for i in range(8):
		counter.process_landmarks(upright, float(i) * 0.1)
	for i in range(12):
		counter.process_landmarks(lowered, 1.0 + float(i) * 0.1)
	for i in range(14):
		counter.process_landmarks(upright, 2.2 + float(i) * 0.1)
	assert(counter.total_reps == 1, "One complete squat cycle should count exactly once.")
	var missing: Array = []
	counter.process_landmarks(missing, 4.0)
	assert(counter.total_reps == 1, "Missing landmarks must not add repetitions.")
	print("ExercisePoseCounter tests passed.")
	quit(0)

func _pose(knee_angle: float) -> Array:
	var points: Array = []
	for i in range(33):
		points.append({"x": 0.5, "y": 0.5, "confidence": 1.0})
	# Left knee: hip -> knee -> ankle. Set geometry to the requested angle.
	points[23] = {"x": 0.5, "y": 0.2, "confidence": 1.0}
	points[25] = {"x": 0.5, "y": 0.5, "confidence": 1.0}
	var radians := deg_to_rad(knee_angle)
	points[27] = {"x": 0.5 + sin(radians), "y": 0.5 - cos(radians), "confidence": 1.0}
	# Mirror a valid right side so the counter can average both knees.
	points[24] = {"x": 0.6, "y": 0.2, "confidence": 1.0}
	points[26] = {"x": 0.6, "y": 0.5, "confidence": 1.0}
	points[28] = {"x": 0.6 + sin(radians), "y": 0.5 + cos(radians), "confidence": 1.0}
	return points
