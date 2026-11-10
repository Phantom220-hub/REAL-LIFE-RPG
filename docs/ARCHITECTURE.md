# Architecture

- **Engine:** Godot 4.x, GDScript.
- **Target:** Android first; desktop editor for development.
- **Rendering:** GL Compatibility for broad mobile support.
- **Offline-first:** gameplay and progression are local.
- **Persistence:** Godot ConfigFile in the app's user data directory.
- **UI:** responsive Control nodes created in GDScript for the first prototype.

## Current modules
- `scripts/game_state.gd`: player progression, XP, coins, local save/load.
- `scripts/main.gd`: prototype interface and user actions.
- `scenes/main.tscn`: entry scene.

## Camera recognition plan
Camera processing is a separate milestone. Prefer on-device inference (no network calls), minimal camera permissions, no video storage, and no upload. Validate pose landmarks and repetition state transitions on supported Android hardware before connecting exercise counts to progression.
