# Offline camera and exercise recognition

## Current implementation boundary

`scripts/exercise_pose_counter.gd` contains the exercise state machine. It accepts 33 normalized pose landmarks with confidence values and counts a repetition only after a complete top -> bottom -> top movement. It supports squat knee-angle and push-up elbow-angle tracking, smooths angle noise, rejects low-confidence joints, and applies a minimum interval to reduce duplicate counts.

**This file is not a camera driver or a pose model.** The repository still needs a native Android camera bridge and a bundled on-device pose model before this can run from the phone camera.

## Required Android integration

- Godot 4.7.2 Android Gradle build and Android plugin v2.
- CameraX Preview + ImageAnalysis using the back/front camera with an explicit runtime camera permission.
- Google ML Kit Pose Detection bundled dependency (not the Play Services/unbundled model), so inference works without downloading a model after installation.
- Convert ML Kit's 33 landmarks and per-landmark in-frame confidence into the input dictionary expected by `ExercisePoseCounter.process_landmarks()`.
- Throttle inference (for example 10-15 frames/second), close every ImageProxy after inference, and stop camera/analyzer on pause or when leaving the training screen.
- Camera frames must remain on-device and must never be uploaded or saved.
- Show camera preview, framing guidance, confidence/visibility status, pause/stop controls, and a manual correction option.

## Counting rules

- Squat: knee angle moves from an upright range (>=160°) into a lower range (<=105°), then returns upright.
- Push-up: elbow angle moves from an extended range (>=155°) into a bent range (<=95°), then returns extended.
- Angles are initial heuristic thresholds, not medical or form coaching. They need calibration and real-device testing.
- The counter does not award XP automatically. The game should ask the player to confirm a session and keep the existing daily XP cap.
- Never require exercise to progress; rest remains a valid daily choice.

## Validation still required

The native Android plugin, packaged model, Android export preset, runtime permission flow, device performance, and camera behavior have not yet been built or verified on a physical Samsung Galaxy A16. Do not describe camera counting as available until those checks pass.
