@tool
extends EditorPlugin

var _export_plugin: AndroidPoseExportPlugin

func _enter_tree() -> void:
	_export_plugin = AndroidPoseExportPlugin.new()
	add_export_plugin(_export_plugin)

func _exit_tree() -> void:
	if _export_plugin != null:
		remove_export_plugin(_export_plugin)
		_export_plugin = null

class AndroidPoseExportPlugin extends EditorExportPlugin:
	func _supports_platform(platform: EditorExportPlatform) -> bool:
		return platform is EditorExportPlatformAndroid

	func _get_name() -> String:
		return "RealLifePoseCamera"

	func _get_android_dependencies(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		return PackedStringArray([
			"androidx.camera:camera-core:1.4.2",
			"androidx.camera:camera-camera2:1.4.2",
			"androidx.camera:camera-lifecycle:1.4.2",
			"androidx.camera:camera-view:1.4.2",
			"com.google.mlkit:pose-detection:18.0.0-beta5"
		])
