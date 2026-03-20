extends Node2D

# Script de debug pour afficher uniquement la grille avec les coordonnées

func _ready():
	print("🔍 DÉMARRAGE DEBUG GRILLE")
	display_grid()

func display_grid():
	# Afficher une grille de 25x20 cases avec coordonnées
	var max_cols = 25
	var max_rows = 20

	print("Création d'une grille ", max_cols, "x", max_rows)

	for row in range(max_rows):
		for col in range(max_cols):
			create_grid_cell(col, row)

	print("✅ Grille créée avec succès")

func create_grid_cell(grid_x: int, grid_y: int):
	# Calculer la position monde de cette case
	var world_x = grid_x * GameConstants.CELL_SIZE
	var world_y = grid_y * GameConstants.CELL_SIZE
	var center_x = world_x + GameConstants.HALF_CELL
	var center_y = world_y + GameConstants.HALF_CELL

	# Créer un fond pour la case
	var background = ColorRect.new()
	background.size = Vector2(GameConstants.CELL_SIZE, GameConstants.CELL_SIZE)
	background.position = Vector2(world_x, world_y)
	background.color = Color(0.3, 0.3, 0.3, 0.5)  # Gris semi-transparent
	add_child(background)

	# Créer le label avec les coordonnées
	var label = Label.new()
	label.text = str(grid_x) + "," + str(grid_y)
	label.position = Vector2(world_x + 2, world_y + 2)
	label.size = Vector2(28, 14)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 8)
	add_child(label)

	# Créer un point rouge au centre de la case
	var center_dot = ColorRect.new()
	center_dot.size = Vector2(4, 4)
	center_dot.position = Vector2(center_x - 2, center_y - 2)
	center_dot.color = Color.RED
	add_child(center_dot)

	# Log pour les premières cases
	if grid_x < 3 and grid_y < 3:
		print("Case (", grid_x, ",", grid_y, ") : position=", Vector2(world_x, world_y), " centre=", Vector2(center_x, center_y))