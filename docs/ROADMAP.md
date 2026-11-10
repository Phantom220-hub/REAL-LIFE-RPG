# REAL LIFE RPG — Roadmap

## Prototype 0.1 — Foundation
- [x] Godot project foundation
- [x] Offline local progression save
- [x] XP and levels
- [x] Manual activity entry for interface testing
- [x] Landscape-first Android interface
- [x] GitHub Actions headless validation workflow

## Prototype 0.2 — Playable systems
- [x] Character profile and derived attributes
- [x] Turn-based fantasy encounters with enemy health and rewards
- [x] Enemy tiers and a level-gated fantasy boss encounter
- [x] Inventory, equipable focus artifacts and protective clothing
- [x] Small in-game shop and healing items
- [x] Daily activity-or-rest choice with equal rewards
- [x] Daily XP cap for manual activity records
- [x] Explorable level-gated world map
- [x] Claimable achievements with local rewards

## Prototype 0.3 — Camera feature (not implemented)
- [ ] Android camera permission and preview
- [ ] Offline pose estimation integration
- [ ] Rep counting for one exercise, followed by careful device testing
- [ ] Confidence feedback and manual correction
- [ ] Confirm all camera processing stays on-device and no footage is uploaded

## Later
- [ ] Story quest chain and location-specific scenes
- [ ] More enemies, bosses, character animations and visual effects
- [ ] Accessibility settings and small-screen layout pass
- [ ] Performance and battery optimization
- [ ] Android export and real-device testing

## Important
The current workout screen is manual input only. Do not treat it as camera recognition. Camera recognition needs a tested on-device model and Android integration; it must not upload or store video. The game must support rest days and must never reward unsafe overtraining.

The latest code has passed the headless Godot 4.7.2 validation workflow on the previous source revision. The current daily-refresh change is being checked by GitHub Actions. Real-device Android testing and export are still outstanding.
