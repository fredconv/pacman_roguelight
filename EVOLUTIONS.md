# Evolutions Checklist

## Step 1 - Initialization & Git
- [x] Verify local repository status
- [x] Create `CHANGELOG.md`
- [x] Create `EVOLUTIONS.md`
- [ ] Commit "Initial state before audit"
- [ ] Create branch `feature/architecture-refactor`
- [ ] Switch to branch `feature/architecture-refactor`

## Step 2 - Mapping & Audit
- [ ] Complete project mapping (scenes, scripts, nodes, inheritance, signals, resources, dependencies)
- [ ] Technical audit (modularity, composition, resources, code quality)
- [ ] Deliver full audit report

## Step 3 - Target Architecture Proposal
- [ ] Propose target scene structure
- [ ] Propose components list
- [ ] Propose `.tres` organization
- [ ] Propose modular state machine
- [ ] Provide textual interaction diagram
- [ ] Provide technical justifications
- [ ] Wait for user validation before refactor

## Step 4 - Implementation
- [ ] Apply minimal inheritance (`Entity` -> `Player` / `Enemy`)
- [ ] Move capabilities to components
- [ ] Implement modular state machine states
- [ ] Enforce Call Down / Signal Up
- [ ] Optimize transitions (prefer Tween)
- [ ] Remove unnecessary `_process`
- [ ] Document scripts and update README if needed

## Step 5 - Finalization
- [ ] Update `CHANGELOG.md`
- [ ] Update `EVOLUTIONS.md`
- [ ] Commit "Architecture refactor completed"
- [ ] Push `feature/architecture-refactor`

## Advanced Rules (6.X)
- [ ] Ensure `Local to Scene` is ON for dynamic stats resources
- [ ] Ensure `Local to Scene` is OFF for static stats resources
- [ ] Guard component calls with `has_method()` or `has_meta()`
- [ ] Keep strict modularity and low coupling

## Mandatory Architecture Constraints
- [ ] Respect base inheritance: `Entity` -> `Player` / `Enemy`
- [ ] Keep business logic out of `Player.gd` and `Enemy.gd`
- [ ] Ensure all abilities are modular components
- [ ] Externalize stats into `.tres` resources
- [ ] Organize folders toward target structure
