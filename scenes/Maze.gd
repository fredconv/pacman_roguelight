extends Node2D

# Maze generator and manager
class_name Maze

signal dot_collected
signal power_pellet_collected

# Maze properties
@export var cell_size: int = GameConstants.CELL_SIZE
@export var maze_width: int = 19
@export var maze_height: int = 21

# Maze data
var maze_data: Array[Array] = []
var dots: Array = []
var power_pellets: Array = []
var walls: Array[StaticBody2D] = []

# Maze symbols
enum CellType {
	WALL,
	DOT,
	POWER_PELLET,
	EMPTY,
	SPAWN_POINT,
	GHOST_SPAWN
}

# Default maze layout (classic Pac-Man style)
var default_maze: Array[String] = [
	"###################",
	"#........#........#",
	"#.##.###.#.###.##.#",
	"#*...............*#",
	"#.##.#.#####.#.##.#",
	"#....#...#...#....#",
	"####.###.#.###.####",
	"   #.#.......#.#   ",
	"####.#.## ##.#.####",
	"#......#GGG#......#",
	"####.#.#####.#.####",
	"   #.#.......#.#   ",
	"####.#.#####.#.####",
	"#........#........#",
	"#.##.###.#.###.##.#",
	"#*.#.....P.....#.*#",
	"##.#.#.#####.#.#.##",
	"#....#...#...#....#",
	"#.######.#.######.#",
	"#.................#",
	"###################"
]

var maze_level_2: Array[String] = [
    "#################",
    "#*#...#.#...#.#*#",
    "#.#.###.#.###.#.#",
    "#.........#...#.#",
    "###.###.#.#.###.#",
    "#.#.#.#.#...#...#",
    "#...#.#.#.#.#.#.#",
    "#.###.#.###.#.###",
    "#.#...#.#.#.#.#.#",
    "#.#.#....G......#",
    "#.###.#####.#.###",
    "#...#.#.....#...#",
    "#.###.#####.#.###",
    "#.#...........#.#",
    "#.###.#.#.#.###.#",
    "#*......#P#....*#",
    "#################"
]

var maze_level_3: Array[String] = [
    "###################",
    "#*...............*#",
    "#.###############.#",
    "#.##.##.#.##.##...#",
    "#.##.#.......#.##.#",
    "#....#.##.##.#....#",
    "#.##.####.####.##.#",
    "#.#..#....G....##.#",
    "#.###.####.####.###",
    "#.#.....P.....#...#",
    "#.###.####.####.###",
    "#.##.##....#.##.#.#",
    "#......#...#.#....#",
    "#.##.####.##.#.##.#",
    "#.##.##.#.##.##.#.#",
    "#*...............*#",
    "###################"
]

var maze_level_4: Array[String] = [
    "#################",
    "#*.#...#.#...#.*#",
    "#.##.#.#.#.#.##.#",
    "#...............#",
    "#.##.#.#.#.#.##.#",
    "#.#..#.....#..#.#",
    "#.##.###.###.##.#",
    "#...#.......#...#",
    "###.#########.###",
    "#...G...G...G...#",
    "###.#########.###",
    "#...#.......#...#",
    "#.##.###.###.##.#",
    "#.#..#.....#..#.#",
    "#.##.#.#P#.#.##.#",
    "#*.............*#",
    "#################"
]

func _ready():
	print("🏗️ Maze _ready() - En attente de commande de génération")
	# Ne plus générer automatiquement - laisser Game.gd décider du niveau
	# generate_level(1)

func generate_level(level: int):
	clear_level()
	print("🏗️ Génération du niveau ", level)

	# Utiliser les layouts spécifiques selon le niveau
	var selected_maze: Array[String]

	match level:
		1:
			selected_maze = default_maze
			print("🏗️ Utilisation du layout par défaut")
		2:
			selected_maze = maze_level_2
			print("🏗️ Utilisation du layout niveau 2")
		3:
			selected_maze = maze_level_3
			print("🏗️ Utilisation du layout niveau 3")
		4:
			selected_maze = maze_level_4
			print("🏗️ Utilisation du layout niveau 4")
		_:
			# Pour les niveaux > 4, utiliser le niveau 4 modifié
			selected_maze = modify_maze_for_level(maze_level_4, level)
			print("🏗️ Utilisation du layout niveau 4 modifié pour niveau ", level)

	generate_from_template(selected_maze)
	print("✅ Niveau ", level, " généré avec succès")

func generate_from_template(template: Array[String]):
	maze_data.clear()

	# Calculer dynamiquement les dimensions du niveau actuel
	maze_height = template.size()
	maze_width = template[0].length() if template.size() > 0 else 19
	print("🏗️ Dimensions du niveau: ", maze_width, " × ", maze_height)

	for row in range(template.size()):
		var maze_row = []
		for col in range(template[row].length()):
			var cell_char = template[row][col]
			var cell_type = get_cell_type_from_char(cell_char)
			maze_row.append(cell_type)

			var world_pos = Vector2(col * cell_size, row * cell_size)
			create_cell_content(cell_type, world_pos)

		maze_data.append(maze_row)

func get_cell_type_from_char(cell_char: String) -> CellType:
	match cell_char:
		"#":
			return CellType.WALL
		".":
			return CellType.DOT
		"*":
			return CellType.POWER_PELLET
		" ":
			return CellType.EMPTY
		"P":
			return CellType.SPAWN_POINT
		"G":
			return CellType.GHOST_SPAWN
		_:
			return CellType.EMPTY

func create_cell_content(cell_type: CellType, pos: Vector2):
	match cell_type:
		CellType.WALL:
			create_wall(pos)
		CellType.DOT:
			create_dot(pos)
		CellType.POWER_PELLET:
			create_power_pellet(pos)
		CellType.SPAWN_POINT:
			# Player spawn point - handled by game manager
			pass
		CellType.GHOST_SPAWN:
			# Ghost spawn point - handled by game manager
			pass

func create_wall(pos: Vector2):
	var wall = StaticBody2D.new()
	var sprite = Sprite2D.new()
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()

	# Set up wall appearance
	shape.size = Vector2(cell_size, cell_size)
	collision.shape = shape

	# Create a simple wall texture (colored rectangle)
	var image = Image.create(cell_size, cell_size, false, Image.FORMAT_RGB8)
	image.fill(Color.BLUE)
	var texture = ImageTexture.new()
	texture.set_image(image)
	sprite.texture = texture

	wall.add_child(sprite)
	wall.add_child(collision)
	wall.position = pos + Vector2(cell_size * 0.5, cell_size * 0.5)
	wall.collision_layer = 1  # Wall layer

	add_child(wall)
	walls.append(wall)

func create_dot(pos: Vector2):
	var dot_scene = preload("res://scenes/Dot.gd")
	var dot = Area2D.new()
	dot.set_script(dot_scene)
	dot.position = pos + Vector2(cell_size * 0.5, cell_size * 0.5)
	dot.collected.connect(_on_specific_dot_collected.bind(dot))

	add_child(dot)
	dots.append(dot)

func create_power_pellet(pos: Vector2):
	var pellet_scene = preload("res://scenes/PowerPellet.gd")
	var pellet = Area2D.new()
	pellet.set_script(pellet_scene)
	pellet.position = pos + Vector2(cell_size * 0.5, cell_size * 0.5)
	pellet.collected.connect(_on_specific_pellet_collected.bind(pellet))

	add_child(pellet)
	power_pellets.append(pellet)

func modify_maze_for_level(base_maze: Array[String], level: int) -> Array[String]:
	# For higher levels, could add more complexity
	var modified = base_maze.duplicate()

	# Example: Add more walls or change layout slightly
	if level > 3:
		# Could modify the maze here for increased difficulty
		pass

	return modified

func clear_level():
	# Remove all dynamic objects
	for dot in dots:
		if is_instance_valid(dot):
			dot.queue_free()
	dots.clear()

	for pellet in power_pellets:
		if is_instance_valid(pellet):
			pellet.queue_free()
	power_pellets.clear()

	for wall in walls:
		if is_instance_valid(wall):
			wall.queue_free()
	walls.clear()

func get_dot_count() -> int:
	return dots.size()

func get_spawn_position() -> Vector2:
	# Find player spawn point in maze
	for row in range(maze_data.size()):
		for col in range(maze_data[row].size()):
			if maze_data[row][col] == CellType.SPAWN_POINT:
				# Position centrée dans la cellule (sprite centré)
				var local_spawn_pos = Vector2(col * cell_size + cell_size * 0.5, row * cell_size + cell_size * 0.5)
				# Convertir en position globale en ajoutant la position du Maze node
				var global_spawn_pos = global_position + local_spawn_pos
				return global_spawn_pos

	# Default spawn if not found (aussi centré)
	print("⚠️ Aucun spawn point trouvé dans le maze - utilisation position par défaut")
	var default_col = maze_width / 2.0
	var default_row = maze_height / 2.0
	var local_default = Vector2(default_col * cell_size + cell_size * 0.5, default_row * cell_size + cell_size * 0.5)
	var global_default = global_position + local_default
	print("🎯 Position par défaut globale: ", global_default)
	return global_default

func get_ghost_spawn_positions() -> Array:
	var positions: Array = []

	# Find ghost spawn points - assurer alignement parfait sur grille
	for row in range(maze_data.size()):
		for col in range(maze_data[row].size()):
			if maze_data[row][col] == CellType.GHOST_SPAWN:
				# Calculer position exactement comme le joueur calcule le centre de grille
				var spawn_x = float(col * cell_size) + float(cell_size) / 2.0
				var spawn_y = float(row * cell_size) + float(cell_size) / 2.0
				var spawn_pos = Vector2(spawn_x, spawn_y)
				positions.append(spawn_pos)
				print("Ghost spawn créé à: ", spawn_pos, " (grille: ", col, ",", row, ")")

	# If no specific spawn points, create some around the center avec alignement parfait
	if positions.is_empty():
		print("Aucun spawn point trouvé, création automatique")
		var center_col = int(float(maze_width) / 2.0)
		var center_row = int(float(maze_height) / 2.0)

		# Créer spawns autour du centre avec même calcul que ci-dessus
		var spawn_offsets = [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]
		for offset in spawn_offsets:
			var col = center_col + int(offset.x)
			var row = center_row + int(offset.y)
			var spawn_x = float(col * cell_size) + float(cell_size) / 2.0
			var spawn_y = float(row * cell_size) + float(cell_size) / 2.0
			positions.append(Vector2(spawn_x, spawn_y))

	return positions

func _on_specific_dot_collected(dot):
	# Supprimer le dot de la liste
	dots.erase(dot)
	dot_collected.emit()

func _on_specific_pellet_collected(pellet):
	# Supprimer le pellet de la liste
	power_pellets.erase(pellet)
	power_pellet_collected.emit()

# Fonctions pour compatibilité (au cas où elles sont encore utilisées)
func _on_dot_collected():
	dot_collected.emit()

func _on_power_pellet_collected():
	power_pellet_collected.emit()