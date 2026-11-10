extends Node
class_name OfflineCameraSession

## Polls the native Android plugin. All camera inference is local; no network API is used.
signal landmarks_received(landmarks: Array)
signal camera_status_changed(message: String)
signal camera_error(message: String)

const PLUGIN_NAME := "RealLifePoseCamera"
var _plugin: Object
var _running := false
var _poll_elapsed := 0.0
const POLL_INTERVAL := 0.10

func _ready() -> void:
	if OS.get_name() == "Android" and Engine.has_singleton(PLUGIN_NAME):
		_plugin = Engine.get_singleton(PLUGIN_NAME)

func is_available() -> bool:
	return _plugin != null

func start_camera() -> bool:
	if _plugin == null:
		camera_status_changed.emit("Нативная камера не включена в эту сборку Android.")
		return false
	if not _plugin.has_method("startCamera"):
		camera_error.emit("В плагине отсутствует startCamera.")
		return false
	var started: bool = bool(_plugin.startCamera())
	if started:
		_running = true
		_poll_elapsed = 0.0
		set_process(true)
		camera_status_changed.emit("Запуск камеры. Если доступ только что разрешён, нажми запуск ещё раз.")
	else:
		camera_status_changed.emit("Разреши доступ к камере, затем нажми запуск ещё раз.")
	return started

func stop_camera() -> void:
	if _plugin != null and _plugin.has_method("stopCamera"):
		_plugin.stopCamera()
	_running = false
	set_process(false)
	camera_status_changed.emit("Камера остановлена.")

func _process(delta: float) -> void:
	if not _running or _plugin == null:
		return
	_poll_elapsed += delta
	if _poll_elapsed < POLL_INTERVAL:
		return
	_poll_elapsed = 0.0
	if _plugin.has_method("getLatestLandmarks"):
		var result: Variant = _plugin.getLatestLandmarks()
		if result is Array and result.size() == 33:
			landmarks_received.emit(result)

func _exit_tree() -> void:
	stop_camera()
