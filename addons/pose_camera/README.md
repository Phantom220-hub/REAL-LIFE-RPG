# Offline pose camera plugin

This addon packages the Android v2 plugin source under `android/posecamera`.
The plugin uses CameraX and the bundled ML Kit pose-detection artifact. The bundled artifact is selected specifically so the pose model is part of the installed app and does not need a first-run network download.

The Android library must be built into an AAR and copied to this addon's expected binary location before an Android export can include it. The Gradle project and Kotlin implementation are under `android/`.

Enable this addon in Project Settings → Plugins and use a Gradle Android export preset. Do not enable it for desktop exports.

Current limitation: camera permission, lifecycle, preview rendering and actual device operation still require a successful Android build and physical-device verification. See `docs/CAMERA_INTEGRATION.md`.
