# Level1.gd
# Premier niveau du jeu - Adapté du code Game.gd existant
extends BaseLevel

func _ready():
	level_number = 1
	super._ready()

func setup_level():
	print("🏗️ Configuration du niveau 1")

	# Créer le maze (utilise le template par défaut niveau 1)
	create_maze()

	# Créer et positionner le joueur
	create_player()

	# Connecter les signaux
	connect_signals()

	# Compter les collectibles
	count_collectibles()

	print("✅ Niveau 1 configuré")

func create_maze():
	"""Créer le maze niveau 1"""
	var maze_script = preload("res://scenes/world/Maze.gd")
	maze = maze_script.new()

	# Générer le niveau 1
	maze.generate_level(1)

	# Ajouter le maze à la zone de jeu
	ui_container.add_child(maze)
	print("🏗️ Maze niveau 1 créé")

func create_player():
	"""Créer et positionner le joueur"""
	var player_scene = preload("res://scenes/actors/Player.tscn")
	player = player_scene.instantiate()
	ui_container.add_child(player)

	# Positionner le joueur au spawn point
	if maze:
		var spawn_pos = maze.get_spawn_position()
		var absolute_pos = maze.global_position + spawn_pos
		player.global_position = absolute_pos
		print("👤 Joueur positionné à: ", absolute_pos)

func connect_signals():
	"""Connecter les signaux des collectibles"""
	# Attendre un frame pour que tous les objets soient créés
	await get_tree().process_frame

	# Connecter les signaux des dots
	var dots = get_tree().get_nodes_in_group("dots")
	for dot in dots:
		if dot.has_signal("collected"):
			dot.collected.connect(_on_dot_collected)

	# Connecter les signaux des pellets
	var pellets = get_tree().get_nodes_in_group("power_pellets")
	for pellet in pellets:
		if pellet.has_signal("collected"):
			pellet.collected.connect(_on_pellet_collected)

	print("� Signaux connectés: ", dots.size(), " dots, ", pellets.size(), " pellets")

func count_collectibles():
	"""Compter les collectibles du niveau"""
	# Attendre un frame pour que tous les objets soient créés
	await get_tree().process_frame

	var dots = get_tree().get_nodes_in_group("dots")
	var pellets = get_tree().get_nodes_in_group("power_pellets")

	dots_remaining = dots.size()
	pellets_remaining = pellets.size()
	collectibles_remaining = dots_remaining + pellets_remaining

	update_ui()
	print("🎯 Collectibles total: ", collectibles_remaining, " (dots: ", dots_remaining, ", pellets: ", pellets_remaining, ")")

# Gestionnaires de signaux
func _on_dot_collected():
	"""Gestionnaire pour collecte de dot"""
	dots_remaining -= 1
	on_collectible_collected(10)  # 10 points par dot

func _on_pellet_collected():
	"""Gestionnaire pour collecte de pellet"""
	pellets_remaining -= 1
	on_collectible_collected(50)  # 50 points par pellet