# Proposition d'Architecture Cible - Pacman Roguelite

Date: 2026-03-20
Branche: feature/architecture-refactor

## 1. Objectif

Construire une architecture modulaire et composable autour d'une base `Entity`, avec capacités sous forme de composants, ressources `.tres` pour les données, et state machine découplée.

## 2. Structure de dossiers cible

```text
res://
  core/
    entity/
      Entity.tscn
      Entity.gd
      components/
        MovementComponent.gd
        StatsComponent.gd
        HealthComponent.gd
        DamageReceiverComponent.gd
        DamageDealerComponent.gd
        StateMachine.gd
        states/
          IdleState.gd
          MoveState.gd
          ChaseState.gd
          FleeState.gd
  actors/
    player/
      Player.tscn
      Player.gd
    enemies/
      Enemy.tscn
      Enemy.gd
      GhostChaser.tscn
      GhostShooter.tscn
  abilities/
    dash/
      DashComponent.gd
      DashStats.tres
    shoot/
      ShootComponent.gd
      Projectile.tscn
      ShootStats.tres
  resources/
    stats/
      PlayerStats.tres
      EnemyStats_Chaser.tres
      EnemyStats_Shooter.tres
  gameplay/
    pickups/
      PickupBase.tscn
      PickupBase.gd
      PickupStats_Speed.tres
      PickupStats_Dash.tres
```

## 3. Héritage et composition

Hiérarchie stricte:

```text
Entity (base)
  ├── Player
  └── Enemy
```

Règles:

- `Entity` contient uniquement le tronc commun (mouvement, stats, santé, collisions, state machine).
- `Player` et `Enemy` ne conservent que le wiring et les comportements spécifiques minimaux.
- Toute capacité est un composant enfant activable/désactivable.

## 4. Liste de composants

Composants communs (`Entity`):

- `MovementComponent`
- `StatsComponent`
- `HealthComponent`
- `DamageReceiverComponent`
- `StateMachine`

Composants optionnels (Player/Enemy):

- `ShootComponent`
- `DashComponent`
- `AbilityComponent` (buffs/powerups)
- `EnemyAIComponent`
- `DamageDealerComponent`

## 5. Ressources `.tres`

Ressources à introduire:

- `PlayerStats.tres`
- `EnemyStats_Chaser.tres`
- `EnemyStats_Shooter.tres`
- `DashStats.tres`
- `ShootStats.tres`

Règles `Local To Scene`:

- ON: valeurs dynamiques (HP courant, cooldown courant, états temporaires).
- OFF: valeurs statiques (vitesse de base, dégâts de base, archetype ennemi).

## 6. State machine modulaire

Structure:

```text
StateMachine
  ├── IdleState
  ├── MoveState
  ├── ChaseState
  └── FleeState
```

Contrat état:

- `enter()`
- `exit()`
- `update(delta)`

Contraintes:

- Les états n'accèdent pas directement à `Player` ou `Enemy`.
- Les états manipulent uniquement l'interface de `Entity`.

## 7. Diagramme textuel des interactions

```text
GameController
  -> Entity (call down)
      -> MovementComponent
      -> StatsComponent
      -> HealthComponent
      -> StateMachine
      -> [Optional] Dash/Shoot/AI

Components
  -> Entity (signal up)
      -> GameController/HUD (signal relay)

Pickups/Projectiles
  -> DamageReceiverComponent (has_method/has_meta guard)
  -> HealthComponent
  -> Entity emits health/status signals upward
```

## 8. Communication et robustesse

Pattern:

- Call Down: parent appelle explicitement ses composants.
- Signal Up: composants notifient parent/système.

Sécurité d'appel inter-composants:

- Vérifier `has_method()` ou `has_meta()` avant invocation.

Exemple:

```gdscript
if component.has_method("apply_damage"):
    component.apply_damage(amount)
```

## 9. Performance

- Tween prioritaire pour transitions simples (UI, flash, petits mouvements).
- AnimationPlayer réservé aux animations complexes.
- Éviter les `_process` inutiles, privilégier événements et physics ciblé.

## 10. Stratégie de migration proposée

1. Créer la nouvelle arborescence sans casser l'existant.
2. Introduire `Entity` + composants communs minimalement.
3. Migrer `Player` vers `actors/player/` avec adaptation progressive.
4. Introduire `Enemy` de base + un premier ennemi migré.
5. Introduire state machine modulaire et brancher un flux minimal.
6. Externaliser stats en `.tres` et activer règles `Local To Scene`.
7. Basculer progressivement `Game.gd` vers orchestration légère.
8. Mettre à jour tests/diagnostics.

## 11. Justification technique

- Réduit le couplage par composition explicite.
- Facilite l'ajout de nouvelles capacités sans toucher aux classes racines.
- Rend le balancing plus simple via ressources de données.
- Améliore testabilité (composants isolables).
- Clarifie responsabilités de chaque nœud.

## 12. Point de validation

Conformément au process, aucune refactorisation de code n'est engagée tant que cette proposition n'est pas validée.
