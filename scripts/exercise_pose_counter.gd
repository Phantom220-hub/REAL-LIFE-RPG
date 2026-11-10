extends RefCounted
class_name ExercisePoseCounter

## Receives ML Kit pose landmarks as 33 dictionaries:
## {"x": float, "y": float, "confidence": float}.
## Coordinates are normalized to 0..1. This class never accesses the camera.
signal repetition_counted(total: int)
signal feedback_changed(message: String)

enum Exercise { SQUAT, PUSH_UP }

const MIN_CONFIDENCE := 0.55
const SMOOTHING := 0.35
const SQUAT_DOWN_ANGLE := 105.0
const SQUAT_UP_ANGLE := 160.0
const PUSH_DOWN_ANGLE := 95.0
const PUSH_UP_ANGLE := 155.0
const MIN_REP_SECONDS := 0.65

var exercise: Exercise = Exercise.SQUAT
var total_reps: int = 0
var _phase: String = "ready"
var _smoothed_angle: float = -1.0
var _last_rep_time: float = -100.0

func set_exercise(value: Exercise) -> void:
	exercise = value
	reset_session()

func reset_session() -> void:
	total_reps = 0
	_phase = "ready"
	_smoothed_angle = -1.0
	_last_rep_time = -100.0
	feedback_changed.emit("Встань так, чтобы всё тело было видно камере.")

func process_landmarks(landmarks: Array, now_seconds: float) -> void:
	var angle := _get_exercise_angle(landmarks)
	if angle < 0.0:
		feedback_changed.emit("Не вижу нужные суставы. Отодвинься и проверь освещение.")
		return
	if _smoothed_angle < 0.0:
		_smoothed_angle = angle
	else:
		_smoothed_angle = lerpf(_smoothed_angle, angle, SMOOTHING)
	_update_phase(_smoothed_angle, now_seconds)

func _get_exercise_angle(points: Array) -> float:
	if exercise == Exercise.SQUAT:
		var left := _angle_from_points(points, 23, 25, 27)
		var right := _angle_from_points(points, 24, 26, 28)
		return _best_visible_angle(left, right)
	var left_arm := _angle_from_points(points, 11, 13, 15)
	var right_arm := _angle_from_points(points, 12, 14, 16)
	return _best_visible_angle(left_arm, right_arm)

func _best_visible_angle(a: float, b: float) -> float:
	if a >= 0.0 and b >= 0.0:
		return (a + b) * 0.5
	return maxf(a, b)

func _angle_from_points(points: Array, a: int, b: int, c: int) -> float:
	if points.size() < 33:
		return -1.0
	var pa := _point(points[a])
	var pb := _point(points[b])
	var pc := _point(points[c])
	if pa.is_empty() or pb.is_empty() or pc.is_empty():
		return -1.0
	var va: Vector2 = pa["position"] - pb["position"]
	var vc: Vector2 = pc["position"] - pb["position"]
	if va.length() < 0.001 or vc.length() < 0.001:
		return -1.0
	return rad_to_deg(acos(clampf(va.normalized().dot(vc.normalized()), -1.0, 1.0)))

func _point(item: Variant) -> Dictionary:
	if not item is Dictionary:
		return {}
	var confidence := float(item.get("confidence", 1.0))
	if confidence < MIN_CONFIDENCE:
		return {}
	return {
		"position": Vector2(float(item.get("x", 0.0)), float(item.get("y", 0.0)))
	}

func _update_phase(angle: float, now_seconds: float) -> void:
	var down_limit := SQUAT_DOWN_ANGLE if exercise == Exercise.SQUAT else PUSH_DOWN_ANGLE
	var up_limit := SQUAT_UP_ANGLE if exercise == Exercise.SQUAT else PUSH_UP_ANGLE
	if _phase == "ready" and angle >= up_limit:
		_phase = "top"
		feedback_changed.emit("Положение распознано. Выполняй движение в комфортном темпе.")
	elif _phase == "top" and angle <= down_limit:
		_phase = "bottom"
		feedback_changed.emit("Нижняя точка распознана.")
	elif _phase == "bottom" and angle >= up_limit:
		if now_seconds - _last_rep_time >= MIN_REP_SECONDS:
			total_reps += 1
			_last_rep_time = now_seconds
			repetition_counted.emit(total_reps)
			feedback_changed.emit("Повторение засчитано: %d" % total_reps)
		_phase = "top"
