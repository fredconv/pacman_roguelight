# Evolutions Checklist

## Step 1 - Initialization & Git

- [x] Verify local repository status
- [x] Create `CHANGELOG.md`
- [x] Create `EVOLUTIONS.md`
- [x] Commit "Initial state before audit"
- [x] Create branch `feature/architecture-refactor`
- [x] Switch to branch `feature/architecture-refactor`

## Step 2 - Mapping & Audit

- [x] Complete project mapping (scenes, scripts, nodes, inheritance, signals, resources, dependencies)
- [x] Technical audit (modularity, composition, resources, code quality)
- [x] Deliver full audit report

## Step 3 - Target Architecture Proposal

- [x] Propose target scene structure
- [x] Propose components list
- [x] Propose `.tres` organization
- [x] Propose modular state machine
- [x] Provide textual interaction diagram
- [x] Provide technical justifications
- [x] Wait for user validation before refactor

## Step 4 - Implementation

- [x] Apply minimal inheritance (`Entity` -> `Player` / `Enemy`)
- [x] Move capabilities to components
- [x] Implement modular state machine states
- [x] Enforce Call Down / Signal Up
- [x] Optimize transitions (prefer Tween)
- [x] Remove unnecessary `_process`
- [x] Document scripts and update README if needed

## Step 5 - Finalization

- [x] Update `CHANGELOG.md`
- [x] Update `EVOLUTIONS.md`
- [x] Commit "Architecture refactor completed"
- [x] Push `feature/architecture-refactor`

## Advanced Rules (6.X)

- [x] Ensure `Local to Scene` is ON for dynamic stats resources
- [x] Ensure `Local to Scene` is OFF for static stats resources
- [x] Guard component calls with `has_method()` or `has_meta()`
- [x] Keep strict modularity and low coupling

## Mandatory Architecture Constraints

- [x] Respect base inheritance: `Entity` -> `Player` / `Enemy`
- [x] Keep business logic out of `Player.gd` and `Enemy.gd`
- [x] Ensure all abilities are modular components
- [x] Externalize stats into `.tres` resources
- [x] Organize folders toward target structure

## Abilities System

- [x] Create `AbilityData.gd`
- [x] Rework entity `AbilityComponent.gd` as installed-abilities container
- [x] Create `AbilityManager.gd` autoload
- [x] Create folders `abilities/components` and `abilities/ability_list`
- [x] Implement dynamic pool with random draw of 3 choices
- [x] Remove chosen ability from pool and enqueue next level
- [x] Add `ExtraLife` levels 1-3
- [x] Add `Dash` levels 1-3
- [x] Add `SpeedBoost` levels 1-3
- [x] Add `Invisibility` levels 1-3 scaffold
- [x] Add `ParalysisShot` levels 1-3 scaffold
- [x] Add `DestructiveShot` levels 1-3 scaffold
- [x] Add `Mines` levels 1-3 scaffold with `Mine.tscn`
- [x] Add upgrade UI with 3 random choices
- [x] Integrate ability choice after player death
- [x] Apply chosen ability to player on respawn
- [x] Keep system ready to add more abilities later
