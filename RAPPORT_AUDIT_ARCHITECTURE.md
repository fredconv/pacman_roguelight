# Rapport d'Audit Architecture - Pacman Roguelite

Date: 2026-03-20
Branche: feature/architecture-refactor

## 1. Cartographie du projet

### Scènes principales détectées

- `scenes/MainGame.tscn` + `scenes/MainGame.gd`
- `scenes/MainMenu.tscn` + `scenes/MainMenu.gd`
- `scenes/Game.tscn` + `scenes/Game.gd`
- `scenes/GameSimple.tscn` + `scenes/Game.gd`
- `scenes/Player.tscn` + `components/Player.gd`
- `scenes/Maze.gd` (instanciée dynamiquement)
- `scenes/HUD.gd` (UI gameplay)
- `scenes/levels/Level1.tscn` + `scenes/levels/Level1.gd`

### Scripts principaux et responsabilités

- `components/BaseEntity.gd`: base d'entité, initialisation des composants principaux.
- `components/Player.gd`: logique spécifique joueur, score, vies, états.
- `components/HealthComponent.gd`: gestion PV/dégâts/mort.
- `components/MovementComponent.gd`: déplacement directionnel.
- `components/AbilityComponent.gd`: capacités dynamiques.
- `scenes/Game.gd`: orchestration gameplay (niveau, joueur, HUD, score, progression).
- `scenes/Maze.gd`: génération grille + dots + power pellets.
- `scenes/SceneManager.gd` et `scenes/GameManager.gd`: gestion transitions/état global.

### Héritage observé

- `BaseEntity` étend `CharacterBody2D`.
- `Player` étend `BaseEntity`.
- `SimpleGhost` et `SimpleGhostSafe` étendent `CharacterBody2D` (pas de base Enemy commune).
- `Dot` et `PowerPellet` étendent `Area2D`.

### Signaux observés (extraits)

- Entités/composants: `health_changed`, `entity_died`, `ability_used`, `movement_started`, `direction_changed`.
- Gameplay: `dot_collected`, `power_pellet_collected`, `score_changed`, `lives_changed`, `game_over`.
- Managers: `scene_changed`, `scene_change_started`, `scene_change_failed`, `game_started`.

### Ressources détectées

- Scènes `.tscn` présentes dans `scenes/`, `test/` et `addons/`.
- Aucune ressource gameplay `.tres`/`.res` détectée pour les stats/capacités.
- Assets visuels présents sous `Assets/` avec chargements dynamiques dans plusieurs scripts.

### Dépendances internes

- Couplage fort entre `scenes/Game.gd` et plusieurs modules (Player, Maze, HUD, managers).
- Composants majoritairement attachés dynamiquement depuis `BaseEntity`.
- Chargements de scripts/scènes via chemins `res://` distribués dans plusieurs fichiers.

## 2. Audit technique

### Modularité

Constat:

- Un début de modularité existe (components dédiés), mais l'orchestration reste concentrée.
- `Game.gd` est volumineux et centralise trop de responsabilités.

Risque:

- Maintenabilité faible quand le gameplay grandit.

### Composition

Constat:

- La composition est partiellement en place via `HealthComponent`, `MovementComponent`, `AbilityComponent`.
- Pas de `Enemy` commun basé sur `Entity` à ce stade.

Risque:

- Incohérence d'architecture entre acteur joueur et ennemis.

### Ressources

Constat:

- Stats et capacités non externalisées en `.tres`.
- Pas de distinction explicite statique/dynamique via `Local To Scene`.

Risque:

- Réglages difficiles, risque d'effets de bord futurs.

### Qualité de code

Constat:

- Présence de typage et signaux utiles.
- Nommage globalement clair.
- Séparation logique incomplète (logique métier encore côté scènes principales).

Risque:

- Complexité croissante et tests plus coûteux.

## 3. Écarts majeurs vs cible demandée

- Pas de base `Entity` centralisée conforme à la structure cible (`core/entity/Entity.gd`).
- Pas de hiérarchie explicite `Entity -> Player` et `Entity -> Enemy` dans l'arborescence cible.
- Pas de `StateMachine` modulaire avec états enfants (`Idle`, `Move`, `Chase`, `Flee`).
- Pas de ressources `.tres` structurées pour stats/abilities.
- Arborescence cible (`core/`, `actors/`, `abilities/`, `resources/`, `gameplay/`) non en place.

## 4. Priorités de refactor

1. Introduire `Entity` + composants communs stricts.
2. Introduire `Enemy` et réaligner Player/Enemy sur la même base.
3. Externaliser les stats/capacités en `.tres` avec règles `Local To Scene`.
4. Ajouter `StateMachine` modulaire orientée états enfants.
5. Réduire `Game.gd` en déléguant la logique aux composants/services.

## 5. Conclusion

Le projet dispose de fondations utiles (composants, signaux, découpage de base), mais n'atteint pas encore la cible d'architecture 100% compositionnelle et scalable demandée.

Ce rapport clôt l'étape 2 (cartographie + audit) et sert de base pour la proposition d'architecture cible (étape 3).
