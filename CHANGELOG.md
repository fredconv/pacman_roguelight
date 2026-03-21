# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-03-21

### Added

- Modular abilities runtime with `AbilityManager`, `AbilityData`, and level-based `.tres` resources.
- Random 3-choice upgrade flow shown when the player loses the last available life.
- First scalable ability set with 3 upgrade levels each: `ExtraLife`, `Dash`, and `SpeedBoost`.
- Scaffolding resources/scenes for `Invisibility`, `ParalysisShot`, `DestructiveShot`, and `Mines` including `Mine.tscn`.
- Player integration for persistent lives bonus, dash movement over grid cells, and respawn with chosen ability.

## [0.1.0] - 2026-03-20

### Added

- New modular architecture foundation under `core/`, `actors/`, `abilities/`, `resources/`, and `gameplay/`.
- New base `Entity` with component-based movement, stats, health, damage receiving, and modular state machine.
- New actor scenes and scripts for player and enemy variants (`Player`, `Enemy`, `GhostChaser`, `GhostShooter`).
- New reusable capability components (`DashComponent`, `ShootComponent`, `DamageDealerComponent`, `EnemyAIComponent`).
- New state scripts (`IdleState`, `MoveState`, `ChaseState`, `FleeState`) and state machine wiring.
- New resources `.tres` for stats and abilities, with explicit `resource_local_to_scene` usage.
- New pickup foundation (`PickupBase`) and pickup stats resources.

## [0.0.1] - 2026-03-20

### Added

- Initial state before audit.
- Git tracking and initial project baseline.
