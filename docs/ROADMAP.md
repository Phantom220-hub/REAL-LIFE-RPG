# REAL LIFE RPG — Roadmap

## Prototype 0.1 — Foundation
- [x] Godot project foundation
- [x] Offline local progression save
- [x] XP and levels
- [x] Manual activity entry for interface testing
- [x] Initial encounter flow
- [x] Landscape-first Android interface
- [x] GitHub Actions headless validation workflow (added; execution result still pending)

## Prototype 0.2 — Playable systems
- [x] Character profile and derived attributes
- [x] Turn-based fantasy encounters with enemy health and rewards
- [x] Enemy tiers and a level-gated boss encounter
- [x] Inventory, equipment and a small in-game shop
- [x] Healing items and rest-based recovery
- [x] Daily activity-or-rest choice with equal rewards
- [x] Daily XP cap so the game does not reward excessive exercise

## Prototype 0.3 — Camera feature (not implemented)
- [ ] Android camera permission and preview
- [ ] Offline pose estimation integration
- [ ] Rep counting for one exercise, followed by careful device testing
- [ ] Confidence feedback and manual correction
- [ ] Confirm all camera processing stays on-device and no footage is uploaded

## Later
- [ ] Explorable world map and location scenes
- [ ] More enemies, bosses and story quests
- [ ] Achievements and accessibility settings
- [ ] Performance, battery and small-screen optimization
- [ ] Android export and real-device testing

## Important
The current workout screen is manual input only. Do not treat it as camera recognition. Camera recognition needs a tested on-device model and Android integration; it must not upload or store video. The game must support rest days and must never reward unsafe overtraining.

The 0.2 systems have been added to source code but are not considered validated until the Godot 4.7.2 CI run succeeds and the app is tested on a real Android device.
