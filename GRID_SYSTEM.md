# Système de Grille - Pacman Roguelite

## Constantes Globales

Toutes les mesures et décalages dans le jeu se basent maintenant sur `GameConstants.CELL_SIZE = 32`.

### Constantes Principales

- **CELL_SIZE**: 32px - Taille de base d'une cellule de la grille
- **HALF_CELL**: 16px - Centre d'une cellule (CELL_SIZE / 2)
- **DOUBLE_CELL**: 64px - Deux cellules (CELL_SIZE \* 2)
- **MAZE_OFFSET_X**: 192px - Décalage du labyrinthe pour l'UI (6 \* CELL_SIZE)

### Vitesses Basées sur la Grille

- **PLAYER_SPEED**: 200.0 - Vitesse du joueur (6.25 \* CELL_SIZE)
- **GHOST_SPEED**: 100.0 - Vitesse des fantômes (3.125 \* CELL_SIZE)

### Fonctions Utilitaires

```gdscript
# Conversion grille → monde (avec centrage)
var world_pos = GameConstants.grid_to_world(Vector2(5, 3))  # → (176, 112)

# Conversion monde → grille
var grid_pos = GameConstants.world_to_grid(Vector2(176, 112))  # → (5, 3)

# Alignement sur la grille
var snapped_pos = GameConstants.snap_to_grid(player.position)
```

## Avantages

1. **Cohérence**: Toutes les mesures utilisent la même base
2. **Maintenabilité**: Changer CELL_SIZE modifie tout le jeu proportionnellement
3. **Lisibilité**: `GameConstants.DOUBLE_CELL` est plus clair que `64`
4. **Évolutivité**: Facile d'adapter le jeu à différentes résolutions

## Changements Effectués

### Fichiers Modifiés

- **pacman.gd**: `speed`, positions du sprite (64,64 → DOUBLE_CELL)
- **Maze.gd**: `cell_size` utilise GameConstants.CELL_SIZE
- **Game.gd**: décalage du maze (200 → MAZE_OFFSET_X)
- **SimpleGhost.gd**: `speed`, distances de raycast
- **test_game.gd**: calculs de grille, conversions monde/grille
- **GridDebug.gd**: dimensions et positions des cellules

### Exemple de Conversion

Ancien code:

```gdscript
sprite.position = Vector2(64, 64)  # Valeur "magique"
```

Nouveau code:

```gdscript
sprite.position = Vector2(GameConstants.DOUBLE_CELL, GameConstants.DOUBLE_CELL)  # 2 * CELL_SIZE
```

## Utilisation Future

Lors de l'ajout de nouvelles fonctionnalités, toujours utiliser les constantes:

- Positions: multiples de CELL_SIZE
- Vitesses: multiples de CELL_SIZE pour garder la cohérence
- Détections: utiliser CELL_SIZE pour les distances de raycast
- UI: utiliser CELL_SIZE pour l'espacement et les marges
