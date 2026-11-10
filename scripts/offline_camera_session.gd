extends Node
class_name OfflineCameraSession

## GDScript adapter for the native Android pose-camera plugin.
## Pose inference must be bundled in the APK; this class never uses HTTP or networking.

signal landmarks_received(landmarks: Array)
signal camera_status_changed(message: String)
signal camera_error(message: String)

const PLUGIN_NAME := "RealLifePoseCamera"
var _plugin: Object
var _running := false

func _ready() -> void:
	if OS.get_name() == "Android" and Engine.has_singleton(PLUGIN_NAME):
		_plugin = Engine.get_singleton(PLUGIN_NAME)
		if _plugin.has_signal("pose_landmarks"):
			_plugin.pose_landmarks.connect(_on_pose_landmarks)
		if _plugin.has_signal("camera_error"):
			_plugin.camera_error.connect(_on_camera_error)

func is_available() -> bool:
	return _plugin != null

func start_camera() -> bool:
	if _plugin == null:
		camera_status_changed.emit("Камера упражнений пока недоступна в этой сборке.")
		return false
	if _running:
		return true
	if not _plugin.has_method("startCamera"):
		camera_error.emit("В Android-плагине отсутствует метод startCamera.")
		return false
	var result: Variant = _plugin.startCamera()
	_running = bool(result)
	camera_status_changed.emit("Камера запущена офлайн." if _running else "Не удалось запустить камеру.")
	return _running

func stop_camera() -> void:
	if _plugin != null and _plugin.has_method("stopCamera"):
		_plugin.stopCamera()
	_running = false
	camera_status_changed.emit("Камера остановлена.")

func _on_pose_landmarks(landmarks: Array) -> void:
	if _running:
		landmarks_received.emit(landmarks)

func _on_camera_error(message: String) -> void:
	_running = false
	camera_error.emit(str(message))

func _exit_tree() -> void:
	stop_camera()
