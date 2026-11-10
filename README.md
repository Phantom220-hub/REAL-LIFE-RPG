# REAL LIFE RPG

An offline-first mobile RPG prototype where real-world activity contributes to character progression.

## Current prototype
- Godot 4.x / GDScript project.
- Offline XP, levels, coins and progression saved locally on the device.
- Manual workout entry for testing the progression loop.
- A basic placeholder encounter to test the game interface.
- Mobile-friendly UI using the GL Compatibility renderer.

## Run in Godot
1. Open this repository in Godot 4.x.
2. Import the project and open `scenes/main.tscn`.
3. Run the project.

## Important status
This is an early prototype, not a finished game. Camera-based exercise recognition is **not implemented yet**. It needs a separate offline on-device pose-estimation integration and real Android device testing. The current manual workout entry is only a temporary test interface.

All progression is local. The intended camera feature must process frames on-device and must not upload video. The game should encourage sustainable activity and recovery, not excessive exercise.

See [ROADMAP](docs/ROADMAP.md) and [ARCHITECTURE](docs/ARCHITECTURE.md).
