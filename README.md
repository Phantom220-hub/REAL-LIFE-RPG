# REAL LIFE RPG

An offline-first horizontal mobile RPG prototype where real-world activity contributes to character progression.

## Current prototype
- Godot 4.x / GDScript project using the GL Compatibility renderer.
- Landscape-friendly navigation: Home, Character, Training and Adventure.
- Original hero portrait drawn procedurally in Godot; no external image or network dependency.
- Offline XP, levels, coins and progression saved locally on the device.
- Manual workout entry for testing the progression loop.
- A clearly labelled placeholder encounter for testing the adventure screen.

## Run in Godot
1. Open this repository in Godot 4.x.
2. Import the project and open `scenes/main.tscn`.
3. Run the project.

## Important status
This is an early prototype, not a finished game. Camera-based exercise recognition, animated characters, a real world map, boss encounters and full combat are **not implemented yet**. Camera recognition needs a separate offline on-device pose-estimation integration and real Android device testing. The current manual workout entry is only a temporary test interface.

All progression is local. The intended camera feature must process frames on-device and must not upload video. The game should encourage sustainable activity and recovery, not excessive exercise.

See [ROADMAP](docs/ROADMAP.md) and [ARCHITECTURE](docs/ARCHITECTURE.md).
