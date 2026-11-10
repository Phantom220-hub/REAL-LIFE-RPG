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

	func _get_android_libraries(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		var aar_path := "res://addons/pose_camera/bin/posecamera-release.aar"
		if FileAccess.file_exists(aar_path):
			return PackedStringArray(["pose_camera/bin/posecamera-release.aar"])
		push_warning("RealLifePoseCamera AAR is missing. Build android/posecamera and copy its release AAR into addons/pose_camera/bin before exporting.")
		return PackedStringArray()

	func _get_android_dependencies(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		return PackedStringArray([
			"androidx.camera:camera-core:1.4.2",
			"androidx.camera:camera-camera2:1.4.2",
			"androidx.camera:camera-lifecycle:1.4.2",
			"androidx.camera:camera-view:1.4.2",
			"com.google.mlkit:pose-detection:18.0.0-beta5"
		])
