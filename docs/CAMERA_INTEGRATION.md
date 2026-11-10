# Offline camera and exercise recognition

## Offline design

The exercise feature is designed to work with **no internet connection** after installation. The camera frames and pose inference stay on the phone. There are no HTTP requests, uploads, cloud inference, accounts, or server dependencies in a workout session.

The intended Android implementation uses the **bundled** Google ML Kit Pose Detection dependency, not the Play Services/unbundled variant. Google's documentation lists pose detection as bundled-only; its model is packaged in the app, so it does not need to be downloaded at first launch. The base model adds approximately 10.1 MB to the app. See [ML Kit Android pose detection](https://developers.google.com/ml-kit/vision/pose-detection/android) and [model installation paths](https://developers.google.com/ml-kit/tips/installation-paths).

## Current implementation

- `scripts/exercise_pose_counter.gd` is the local repetition state machine. It accepts 33 normalized pose landmarks with confidence values and counts only complete top → bottom → top movements for squats and push-ups.
- `scripts/offline_camera_session.gd` is the GDScript adapter for the future native Android plugin singleton `RealLifePoseCamera`. It does not make network requests and safely reports when the native plugin is absent.
- The adapter is not itself a camera driver. A native Android AAR must still be built and packaged before camera capture works in an APK.

## Native Android integration still required

- Godot 4.7.2 Android Gradle build and Android plugin v2.
- CameraX Preview + ImageAnalysis, runtime camera permission, and pause/resume lifecycle handling.
- Bundled ML Kit Pose Detection in `STREAM_MODE`; do not use Play Services or dynamically downloaded models.
- Convert ML Kit's 33 landmarks and in-frame confidence into the dictionaries consumed by `ExercisePoseCounter.process_landmarks()`.
- Use CameraX `STRATEGY_KEEP_ONLY_LATEST`, throttle inference, and always close each `ImageProxy`.
- Stop the camera when leaving training or when the app pauses.
- Camera frames must never be uploaded, recorded, or saved.

Godot 4.7's Android plugin v2 requires an Android library/AAR, a `GodotPlugin` init class, and an `EditorExportPlugin` packaging script. See [Godot 4.7 Android plugin documentation](https://docs.godotengine.org/en/4.7/tutorials/platform/android/android_plugin.html).

## Counting and RPG rules

- Squat: knee angle moves from upright (≥160°) into a lower range (≤105°), then returns upright.
- Push-up: elbow angle moves from extended (≥155°) into bent (≤95°), then returns extended.
- These are initial heuristics, not medical or form coaching; real-device calibration is required.
- A validated repetition can contribute to the current encounter's damage. XP is awarded only after the player confirms the session and the existing daily XP cap is respected.
- Rest remains a valid choice. Never encourage training through pain or exhaustion.

## Verification status

The GDScript counter and adapter are source code only. The native Android camera plugin/AAR, Android export preset, permission flow, actual camera preview, offline model packaging, CI Android build, and Samsung Galaxy A16 device test are **not yet complete or verified**. Do not describe camera counting as available until those checks pass.
