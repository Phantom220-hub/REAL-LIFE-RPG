# Architecture

- **Engine:** Godot 4.7.2, GDScript.
- **Target:** Android first; desktop editor/CI for development.
- **Orientation:** Landscape.
- **Rendering:** GL Compatibility.
- **Offline-first:** gameplay and progression are local.
- **Persistence:** Godot ConfigFile in the app's user data directory.
- **UI:** responsive Control nodes created in GDScript.

## Modules
- `scripts/game_state.gd`: player progression, attributes, turn-based fantasy encounter rules, inventory, equipment, shop, daily choice, health and local save/load.
- `scripts/main.gd`: navigation and Home, Character, Training, Adventure, Inventory and Daily screens.
- `scripts/character_portrait.gd`: original procedural 2D hero portrait, drawn locally by Godot.
- `scenes/main.tscn`: entry scene.
- `.github/workflows/godot-check.yml`: headless import/script parse and main-scene smoke run using Godot 4.7.2.

## Safety and progression design
- Workout entry is manual and temporary; it is not camera recognition.
- Daily XP from recorded activity is capped.
- Daily choice allows either an active-day check-in or a rest day with the same coin reward.
- Rest can restore character health. No streak loss or penalty for taking a break.
- Fantasy encounters are separate game actions and do not require physical activity.

## Camera recognition plan
Camera processing is a separate milestone. Prefer on-device inference, minimal camera permissions, no video storage and no upload. Validate pose landmarks and repetition state transitions on supported Android hardware before connecting counts to progression.
