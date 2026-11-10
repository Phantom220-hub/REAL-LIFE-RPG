# REAL LIFE RPG

An offline-first, landscape mobile RPG prototype where real-world activity can contribute to character progression.

## Implemented prototype systems
- Godot 4.7.2 / GDScript project using GL Compatibility.
- Landscape-first navigation: Home, Character, Training, Adventure, Inventory, Daily, World Map and Achievements.
- Original procedural 2D hero portrait; no external image or network dependency.
- Offline XP, levels, character attributes, health and local save.
- Turn-based fantasy encounters with enemy tiers and a level-gated boss.
- Inventory, equipable fantasy focus artifacts and protective clothing, a small shop and healing items.
- Daily choice between an activity check-in and a rest day; both give the same small reward.
- Daily XP cap for manual activity records.
- Four level-gated world locations and claimable achievements.

## Run in Godot
1. Open this repository in Godot 4.7.2.
2. Import the project and open `scenes/main.tscn`.
3. Run the project.

## Current limitations
- Exercise entry is manual. Camera preview, Android camera permission and offline pose estimation are **not implemented**.
- Story quest chains, dedicated location scenes, full character animations and accessibility settings remain future work.
- The project has not yet been confirmed on a physical Android device. GitHub Actions performs a headless Godot validation run; check the Actions tab for the latest result.

All progression is local. Any future camera feature must process frames on-device and must not upload or store video. The game should encourage sustainable activity and recovery, not excessive exercise.

See [ROADMAP](docs/ROADMAP.md) and [ARCHITECTURE](docs/ARCHITECTURE.md).