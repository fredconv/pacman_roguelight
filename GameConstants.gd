extends Node

# === CONSTANTES GLOBALES DU JEU ===
# Toutes les mesures et décalages se basent sur la grille de base

# Taille de base d'une cellule de la grille (en pixels)
const CELL_SIZE: int = 32

# Décalages et positions basés sur la grille
const HALF_CELL: int = 16  # CELL_SIZE / 2 - centre d'une cellule
const DOUBLE_CELL: int = CELL_SIZE * 2  # 64px - 2 cellules
const MAZE_OFFSET_X: int = CELL_SIZE * 6  # 192px - décalage du labyrinthe (environ 6 cellules)

# Vitesses basées sur la grille (pixels/seconde)
const PLAYER_SPEED: float = CELL_SIZE * 6.25  # 200.0 - vitesse de base du joueur
const GHOST_SPEED: float = CELL_SIZE * 3.125   # 100.0 - vitesse de base des fantômes

# Utilitaires pour convertir entre grille et monde
static func grid_to_world(grid_pos: Vector2) -> Vector2:
	return grid_pos * CELL_SIZE + Vector2(HALF_CELL, HALF_CELL)

static func world_to_grid(world_pos: Vector2) -> Vector2:
	return (world_pos / CELL_SIZE).floor()

static func snap_to_grid(world_pos: Vector2) -> Vector2:
	var grid_pos = world_to_grid(world_pos)
	return grid_to_world(grid_pos)