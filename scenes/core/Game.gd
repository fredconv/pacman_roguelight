extends Node2D

# Contrôleur de jeu simple pour les tests
class_name SimpleGame

signal game_over

@onready var player = $Player
@onready var maze = $Maze

var lives: int = 3
var game_active: bool = true

func _ready():
	print("\n=== GAME._READY APPELÉ ===")
	print("🎮 SimpleGame démarré")

	# Vérifier si un niveau spécifique a été demandé en mode debug
	var scene_manager = get_node_or_null("/root/SceneManager")
	print("Scene Manager trouvé: ", scene_manager != null)

	var level_to_load = 1  # Niveau par défaut

	if scene_manager:
		print("Vérification du meta 'requested_level'...")
		if scene_manager.has_meta("requested_level"):
			level_to_load = scene_manager.get_meta("requested_level")
			print("🎯 Niveau ", level_to_load, " demandé en mode debug")
			scene_manager.remove_meta("requested_level")
		else:
			print("⚠️ Aucun niveau demandé, utilisation du niveau par défaut: 1")

	# Générer le niveau dans le maze
	if maze and maze.has_method("generate_level"):
		print("➡️ Appel de maze.generate_level(", level_to_load, ")")
		maze.generate_level(level_to_load)
		print("✅ Niveau ", level_to_load, " chargé")
	else:
		print("❌ ERREUR: Maze introuvable ou pas de méthode generate_level")

	print("=== FIN GAME._READY ===\n")

	# Créer le layout responsive
	setup_responsive_layout()

	# Positionner le joueur au spawn du maze
	if maze and player:
		var spawn_pos = maze.get_spawn_position()
		player.global_position = spawn_pos
		print("👤 Joueur positionné à: ", spawn_pos)

		# Connecter les signaux de collecte
		maze.dot_collected.connect(_on_dot_collected)
		maze.power_pellet_collected.connect(_on_power_pellet_collected)

	# Spawner un fantôme de test
	spawn_ghost()

func setup_responsive_layout():
	# === STRUCTURE RESPONSIVE COMPLÈTE ===

	# Container principal pour tout l'écran
	var main_container = Control.new()
	main_container.name = "MainContainer"
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(main_container)

	# HBoxContainer pour diviser : UI à gauche | Jeu au centre
	var hbox_main = HBoxContainer.new()
	hbox_main.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_container.add_child(hbox_main)

	# === PARTIE GAUCHE : UI FIXE ===
	var left_vbox = VBoxContainer.new()
	left_vbox.custom_minimum_size = Vector2(250, 0)  # Largeur fixe pour l'UI
	left_vbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	left_vbox.add_theme_constant_override("separation", 10)
	hbox_main.add_child(left_vbox)

	# Panel des stats du jeu
	var ui_container = create_ui_panel()
	left_vbox.add_child(ui_container)

	# Panel de debug (seulement en mode debug)
	if debug_mode:
		# Créer un CanvasLayer pour le debug afin qu'il soit au-dessus de tout
		var debug_canvas = CanvasLayer.new()
		debug_canvas.name = "DebugCanvas"
		debug_canvas.layer = 100
		add_child(debug_canvas)

		debug_panel_node = create_debug_panel()
		debug_panel_node.position = Vector2(10, 80)  # Position fixe en haut à gauche
		debug_canvas.add_child(debug_panel_node)
		print("✅ Debug panel ajouté dans CanvasLayer séparé")

	# === PARTIE CENTRE : ZONE DE JEU RESPONSIVE ===
	var game_area = CenterContainer.new()
	game_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	game_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hbox_main.add_child(game_area)

	# Déplacer le labyrinthe dans la zone de jeu centrée
	if maze:
		# Retirer le maze de sa position actuelle
		if maze.get_parent():
			maze.get_parent().remove_child(maze)
		# L'ajouter dans la zone de jeu centrée
		game_area.add_child(maze)
		maze.position = Vector2.ZERO  # Plus besoin de décalage manuel
		print("🏗️ Maze déplacé dans la zone de jeu centrée")

	# Déplacer le joueur dans la zone de jeu aussi
	if player:
		if player.get_parent():
			player.get_parent().remove_child(player)
		game_area.add_child(player)
		print("👤 Joueur déplacé dans la zone de jeu centrée")

# Fonction de game over simplifiée - peut être appelée plus tard si nécessaire
func trigger_game_over():
	print("💀 Game Over")
	game_active = false
	game_over.emit()

func connect_game_over(callback: Callable):
	game_over.connect(callback)

func get_lives() -> int:
	return lives

func _process(_delta):
	# Vérifier les inputs sur l'écran de victoire (méthode alternative)
	if not game_active and has_node("VictoryScreen"):
		if Input.is_action_just_pressed("dash"):
			print("🎮 ESPACE détecté via _process - démarrage niveau suivant")
			call_deferred("start_next_level")
		elif Input.is_action_just_pressed("ui_cancel"):
			print("🎮 ÉCHAP détecté via _process - fermeture jeu")
			get_tree().quit()

func _on_dot_collected():
	if player:
		player.add_score(10)

	# Vérifier si tous les dots sont collectés
	check_level_complete()

func _on_power_pellet_collected():
	if player:
		player.add_score(50)
		# Activer le mode hunter
		player.activate_hunter_mode()
		print("⚡ Power pellet collecté - Mode HUNTER activé!")

	# Vérifier si tous les dots sont collectés (les power pellets comptent aussi)
	check_level_complete()

func check_level_complete():
	if maze:
		var remaining_dots = maze.get_dot_count()
		var remaining_pellets = maze.power_pellets.size()
		var total_remaining = remaining_dots + remaining_pellets

		print("🎯 Collectibles restants: ", total_remaining, " (dots: ", remaining_dots, ", pellets: ", remaining_pellets, ")")

		# Mettre à jour le compteur dans l'UI
		update_dots_counter()

		if total_remaining == 0:
			trigger_level_complete()

func update_dots_counter():
	if maze and ui_dots_label:
		var remaining_dots = maze.get_dot_count()
		var remaining_pellets = maze.power_pellets.size()
		var total_remaining = remaining_dots + remaining_pellets
		ui_dots_label.text = "Restants: " + str(total_remaining)

func update_level_display():
	if ui_level_label:
		ui_level_label.text = "NIVEAU: " + str(current_level)

func trigger_level_complete():
	print("🎉 NIVEAU TERMINÉ !")
	game_active = false
	show_victory_screen()

func show_victory_screen():
	# === ÉCRAN DE VICTOIRE SIMPLIFIÉ ===

	# Créer l'overlay complet
	var victory_layer = CanvasLayer.new()
	victory_layer.layer = 100
	add_child(victory_layer)

	# Fond semi-transparent
	var background = ColorRect.new()
	background.size = get_viewport().get_visible_rect().size
	background.color = Color(0, 0, 0, 0.8)
	victory_layer.add_child(background)

	# Container centré pour le panel
	var center_container = CenterContainer.new()
	center_container.size = get_viewport().get_visible_rect().size
	victory_layer.add_child(center_container)

	# Panel principal avec style
	var victory_panel = PanelContainer.new()
	victory_panel.custom_minimum_size = Vector2(450, 350)
	var victory_style = create_styled_box(Color(0.1, 0.1, 0.8, 0.95), Color.YELLOW, 12, 3)
	victory_panel.add_theme_stylebox_override("panel", victory_style)
	center_container.add_child(victory_panel)

	# Container vertical principal
	var vbox = VBoxContainer.new()
	apply_container_spacing(vbox, 20)
	victory_panel.add_child(vbox)

	# Titre centré
	var title_container = CenterContainer.new()
	var title = create_styled_label("🎉 NIVEAU TERMINÉ ! 🎉", 32, Color.YELLOW)
	title_container.add_child(title)
	vbox.add_child(title_container)

	# Stats centrées
	var stats_container = CenterContainer.new()
	var stats_vbox = VBoxContainer.new()
	apply_container_spacing(stats_vbox, 10)

	# Score et niveau
	var score_text = "Score Final: " + (str(player.get_score()) if player else "0")
	var score_display = create_styled_label(score_text, 24, Color.WHITE)
	stats_vbox.add_child(score_display)

	var level_display = create_styled_label("Niveau Atteint: " + str(current_level), 20, Color.GREEN)
	stats_vbox.add_child(level_display)

	stats_container.add_child(stats_vbox)
	vbox.add_child(stats_container)

	# Séparateur
	var separator = HSeparator.new()
	separator.add_theme_color_override("separator", Color.WHITE)
	vbox.add_child(separator)

	# Instructions centrées
	var instructions_container = CenterContainer.new()
	var instructions = create_styled_label("Appuyez sur ESPACE pour continuer\nou ÉCHAP pour quitter", 16, Color.CYAN)
	instructions_container.add_child(instructions)
	vbox.add_child(instructions_container)

	# Stocker la référence pour pouvoir la supprimer
	victory_layer.name = "VictoryScreen"

func _input(event):
	# Gérer les inputs sur l'écran de victoire
	if not game_active and has_node("VictoryScreen"):
		print("🎮 Input détecté sur écran de victoire: ", event)
		if event.is_action_pressed("dash"):  # ESPACE
			print("🎮 ESPACE pressé - démarrage niveau suivant")
			# Utiliser un petit délai pour éviter les conflits
			call_deferred("start_next_level")
		elif event.is_action_pressed("ui_cancel"):  # ÉCHAP
			print("🎮 ÉCHAP pressé - fermeture jeu")
			get_tree().quit()

	# Raccourci pour activer/désactiver le mode debug (F1)
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F1:
			toggle_debug_mode()

func _unhandled_input(event):
	# Alternative : gérer les inputs non traités
	if not game_active and has_node("VictoryScreen"):
		print("🎮 Unhandled input sur écran de victoire: ", event)
		if Input.is_action_just_pressed("dash"):  # ESPACE
			print("🎮 ESPACE détecté (unhandled) - démarrage niveau suivant")
			call_deferred("start_next_level")
		elif Input.is_action_just_pressed("ui_cancel"):  # ÉCHAP
			print("🎮 ÉCHAP détecté (unhandled) - fermeture jeu")
			get_tree().quit()

func start_next_level():
	print("🚀 Démarrage du niveau suivant...")

	# Incrémenter le niveau
	current_level += 1
	print("📈 Niveau actuel: ", current_level)

	# Supprimer l'écran de victoire
	print("🗑️ Suppression de l'écran de victoire...")
	var victory_screen = get_node("VictoryScreen")
	if victory_screen:
		victory_screen.queue_free()
		print("✅ Écran de victoire supprimé")
	else:
		print("⚠️ Écran de victoire non trouvé")

	# Réinitialiser le jeu
	print("🔄 Réinitialisation du jeu...")
	game_active = true

	# Réinitialiser le niveau complet
	reset_level_state(current_level)

	# Supprimer tous les anciens fantômes
	print("👻 Suppression des anciens fantômes...")
	var old_ghosts = get_tree().get_nodes_in_group("ghosts")
	for ghost in old_ghosts:
		if is_instance_valid(ghost):
			ghost.queue_free()
			print("👻 Ancien fantôme supprimé")

	# Respawner un nouveau fantôme
	print("👻 Respawn d'un nouveau fantôme...")
	spawn_ghost()
	print("✅ Nouveau fantôme respawné")

	# Mettre à jour l'UI
	print("🖥️ Mise à jour de l'UI...")
	update_dots_counter()
	update_level_display()

	print("✅ Nouveau niveau prêt !")

var ui_score_label: Label
var ui_lives_label: Label
var ui_dots_label: Label
var ui_level_label: Label
var current_level: int = 1
var debug_panel_node: Control  # Référence au panel de debug
var debug_mode: bool = true  # Activer/désactiver le debug

func create_ui_panel() -> Control:
	# === PANEL UI RESPONSIVE (VERSION SIMPLIFIÉE) ===

	# Container principal avec style
	var main_panel = PanelContainer.new()
	main_panel.custom_minimum_size = Vector2(230, 200)
	var panel_style = create_styled_box(Color(0, 0, 0, 0.8), Color.YELLOW)
	main_panel.add_theme_stylebox_override("panel", panel_style)

	# Container vertical principal
	var vbox_main = VBoxContainer.new()
	apply_container_spacing(vbox_main, 10)
	main_panel.add_child(vbox_main)

	# === LABELS SIMPLIFIÉS ===
	ui_score_label = create_styled_label("SCORE: 0", 22, Color.YELLOW)
	vbox_main.add_child(ui_score_label)

	ui_lives_label = create_styled_label("VIES: 3", 18, Color.RED)
	vbox_main.add_child(ui_lives_label)

	ui_level_label = create_styled_label("NIVEAU: " + str(current_level), 18, Color.GREEN)
	vbox_main.add_child(ui_level_label)

	ui_dots_label = create_styled_label("", 16, Color.CYAN)
	update_dots_counter()  # Initialiser le compteur
	vbox_main.add_child(ui_dots_label)

	# Séparateur
	var separator = HSeparator.new()
	separator.add_theme_color_override("separator", Color(0.7, 0.7, 0.7, 0.8))
	vbox_main.add_child(separator)

	# Titre du jeu
	var title_label = create_styled_label("PAC-MAN\nROGUELITE", 16, Color.WHITE)
	vbox_main.add_child(title_label)

	# Connecter les signaux du joueur
	if player:
		player.score_changed.connect(_on_score_changed)
		player.lives_changed.connect(_on_lives_changed)

	return main_panel

func create_debug_panel() -> Control:
	# === PANEL DE DEBUG (VERSION SIMPLIFIÉE) ===

	# Panel principal avec style violet
	var debug_panel = PanelContainer.new()
	debug_panel.custom_minimum_size = Vector2(230, 150)
	debug_panel.mouse_filter = Control.MOUSE_FILTER_PASS  # Laisser passer aux enfants
	var debug_style = create_styled_box(Color(0.2, 0.0, 0.2, 0.8), Color.MAGENTA)
	debug_panel.add_theme_stylebox_override("panel", debug_style)

	# Container vertical
	var debug_vbox = VBoxContainer.new()
	debug_vbox.mouse_filter = Control.MOUSE_FILTER_PASS  # Laisser passer aux enfants
	apply_container_spacing(debug_vbox, 8)
	debug_panel.add_child(debug_vbox)

	# Titre et séparateur
	var debug_title = create_styled_label("🔧 DEBUG LEVELS", 16, Color.MAGENTA)
	debug_vbox.add_child(debug_title)

	var separator = HSeparator.new()
	separator.add_theme_color_override("separator", Color.MAGENTA)
	debug_vbox.add_child(separator)

	# Grid pour les boutons de niveau
	var buttons_grid = GridContainer.new()
	buttons_grid.mouse_filter = Control.MOUSE_FILTER_PASS  # Laisser passer aux enfants
	buttons_grid.columns = 2
	apply_container_spacing(buttons_grid, 5)
	debug_vbox.add_child(buttons_grid)

	# Boutons de niveau (boucle simplifiée)
	for level in range(1, 5):
		var level_button = create_styled_button(
			"LV " + str(level),
			Vector2(50, 30),
			Color(0.1, 0.1, 0.3, 0.9),
			Color.CYAN,
			_on_debug_level_button_pressed.bind(level)
		)
		print("✅ Bouton LV", level, " créé avec mouse_filter = ", level_button.mouse_filter)
		buttons_grid.add_child(level_button)

	# Boutons utilitaires
	var reset_button = create_styled_button(
		"🔄 RESET",
		Vector2(100, 30),
		Color(0.3, 0.1, 0.1, 0.9),
		Color.ORANGE,
		_on_debug_reset_button_pressed
	)
	debug_vbox.add_child(reset_button)

	var menu_button = create_styled_button(
		"🏠 RETOUR MENU",
		Vector2(100, 30),
		Color(0.1, 0.3, 0.1, 0.9),
		Color.LIGHT_GREEN,
		_on_debug_menu_button_pressed
	)
	debug_vbox.add_child(menu_button)

	# Instructions
	var instructions = create_styled_label("F1: Toggle Debug", 10, Color(0.8, 0.8, 0.8, 0.7))
	debug_vbox.add_child(instructions)

	print("✅ Debug panel créé avec tous les mouse_filter configurés")
	return debug_panel

func _on_debug_level_button_pressed(level: int):
	print("🔧 DEBUG: Changement vers le niveau ", level, " via load_scene()")
	load_scene("level" + str(level))

func _on_debug_reset_button_pressed():
	print("🔧 DEBUG: Réinitialisation du niveau ", current_level, " via load_scene()")
	load_scene("level" + str(current_level))

func _on_debug_menu_button_pressed():
	print("🏠 DEBUG: Retour au menu principal demandé")
	load_scene("menu")

# === FONCTION GÉNÉRIQUE DE CHARGEMENT DE SCÈNE ===
func load_scene(scene_type: String):
	"""
	Fonction générique pour charger n'importe quelle scène
	scene_type peut être: "menu", "level1", "level2", "level3", "level4"
	"""
	print("🔄 Chargement de la scène: ", scene_type)

	# Mapping des types de scène vers les actions
	match scene_type:
		"menu":
			_load_main_menu()
		"level1", "level2", "level3", "level4":
			var level_num = int(scene_type.right(-1))  # Extraire le numéro
			_load_level(level_num)
		_:
			print("❌ Type de scène inconnu: ", scene_type)

func _load_main_menu():
	"""Charger le menu principal"""
	print("🏠 Chargement du menu principal...")

	# Méthode 1: Via SceneManager (préféré)
	var scene_manager = get_node_or_null("/root/SceneManager")
	if scene_manager and scene_manager.has_method("return_to_menu"):
		print("✅ SceneManager trouvé - transition vers menu")
		scene_manager.return_to_menu()
	else:
		# Méthode 2: Changement direct de scène (fallback)
		print("⚠️ SceneManager non trouvé - changement direct de scène")
				get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _load_level(level_num: int):
	"""Charger un niveau spécifique et réinitialiser le jeu"""
	print("🎮 Chargement du niveau ", level_num, "...")

	current_level = level_num

	# Réinitialiser les stats du joueur pour le test
	reset_player_stats()

	# Réinitialiser le niveau complet
	reset_level_state(level_num)

	print("✅ Niveau ", level_num, " chargé avec succès!")# === FONCTIONS UTILITAIRES POUR SIMPLIFIER LE CODE UI ===

func create_styled_box(bg_color: Color, border_color: Color, corner_radius: int = 10, border_width: int = 2) -> StyleBoxFlat:
	"""Créer un StyleBoxFlat avec les paramètres donnés"""
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color

	# Coins arrondis uniformes
	style.corner_radius_top_left = corner_radius
	style.corner_radius_top_right = corner_radius
	style.corner_radius_bottom_left = corner_radius
	style.corner_radius_bottom_right = corner_radius

	# Bordures uniformes
	style.border_width_left = border_width
	style.border_width_right = border_width
	style.border_width_top = border_width
	style.border_width_bottom = border_width

	return style

func create_styled_label(text: String, font_size: int, color: Color, alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	"""Créer un Label stylé avec les paramètres donnés"""
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = alignment
	return label

func create_styled_button(text: String, size: Vector2, bg_color: Color, font_color: Color, callback: Callable) -> Button:
	"""Créer un Button stylé avec les paramètres donnés"""
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = size
	button.mouse_filter = Control.MOUSE_FILTER_STOP  # S'assurer que le bouton reçoit les clics
	button.pressed.connect(callback)

	# Désactiver complètement la navigation clavier et le focus
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	var button_style = create_styled_box(bg_color, Color.TRANSPARENT, 5, 0)
	button.add_theme_stylebox_override("normal", button_style)
	button.add_theme_color_override("font_color", font_color)

	return button

func apply_container_spacing(container: Container, spacing: int):
	"""Appliquer un espacement à un container"""
	if container is VBoxContainer or container is HBoxContainer:
		container.add_theme_constant_override("separation", spacing)
	elif container is GridContainer:
		container.add_theme_constant_override("h_separation", spacing)
		container.add_theme_constant_override("v_separation", spacing)

func reposition_player():
	"""Repositionner le joueur au spawn du maze"""
	if maze and player:
		var spawn_pos = maze.get_spawn_position()
		player.global_position = spawn_pos
		print("👤 Joueur repositionné à: ", spawn_pos)
	else:
		print("❌ Impossible de repositionner le joueur (maze:", maze, " player:", player, ")")

func cleanup_ghosts():
	"""Supprimer tous les anciens fantômes"""
	print("👻 Nettoyage des fantômes...")
	var old_ghosts = get_tree().get_nodes_in_group("ghosts")
	for ghost in old_ghosts:
		if is_instance_valid(ghost):
			ghost.queue_free()
	print("✅ Fantômes nettoyés")

func reset_level_state(level_num: int):
	"""Réinitialiser complètement l'état d'un niveau"""
	print("🔄 Réinitialisation du niveau ", level_num, "...")

	# Nettoyer et régénérer le maze
	if maze:
		maze.clear_level()
		maze.generate_level(level_num)
		print("✅ Maze régénéré")

	# Repositionner le joueur
	reposition_player()

	# Nettoyer et respawner les fantômes
	cleanup_ghosts()
	spawn_ghost()

	# Mettre à jour l'UI
	update_dots_counter()
	update_level_display()

	print("✅ Niveau ", level_num, " réinitialisé")

func reset_player_stats():
	"""Réinitialiser les statistiques du joueur"""
	if player:
		player.score = 0
		player.lives = 3
		player.score_changed.emit(player.score)
		player.lives_changed.emit(player.lives)
		print("✅ Stats joueur réinitialisées")

func toggle_debug_mode():
	debug_mode = !debug_mode
	print("🔧 Mode debug: ", "ACTIVÉ" if debug_mode else "DÉSACTIVÉ")

	if debug_panel_node:
		debug_panel_node.visible = debug_mode

	# Si on active le debug et qu'il n'y a pas de panel, le créer
	if debug_mode and not debug_panel_node:
		var left_vbox = get_node("MainContainer").get_child(0).get_child(0)  # HBox > VBox à gauche
		if left_vbox:
			debug_panel_node = create_debug_panel()
			left_vbox.add_child(debug_panel_node)

func _on_score_changed(new_score: int):
	if ui_score_label:
		ui_score_label.text = "SCORE: " + str(new_score)

func _on_lives_changed(new_lives: int):
	if ui_lives_label:
		ui_lives_label.text = "VIES: " + str(new_lives)

func spawn_ghost():
	# Version sécurisée avec fallback
	print("👻 Tentative de spawn du fantôme...")

	var ghost_scene_path = "res://scenes/actors/GhostSafe.tscn"  # Version sécurisée

	# Vérifier que la ressource existe
	if not ResourceLoader.exists(ghost_scene_path):
		print("❌ Fichier ", ghost_scene_path, " introuvable - création fantôme simple")
		create_simple_ghost()
		return

	# Charger et instancier avec gestion d'erreur
	var ghost_scene = load(ghost_scene_path)
	if not ghost_scene:
		print("❌ Impossible de charger ", ghost_scene_path, " - création fantôme simple")
		create_simple_ghost()
		return

	var ghost = ghost_scene.instantiate()
	if not ghost:
		print("❌ Impossible d'instancier le fantôme - création fantôme simple")
		create_simple_ghost()
		return

	# Positionner le fantôme
	position_ghost(ghost)

	# Ajouter le fantôme dans la hiérarchie
	add_ghost_to_scene(ghost)

func create_simple_ghost():
	"""Créer un fantôme simple sans dépendances externes"""
	print("🔧 Création d'un fantôme simple en fallback")

	var ghost = CharacterBody2D.new()
	ghost.name = "SimpleGhost"

	# Ajouter une forme visuelle
	var color_rect = ColorRect.new()
	color_rect.size = Vector2(32, 32)
	color_rect.position = Vector2(-16, -16)
	color_rect.color = Color.MAGENTA
	ghost.add_child(color_rect)

	# Ajouter collision
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 16
	collision.shape = shape
	ghost.add_child(collision)

	# Configurer
	ghost.collision_layer = 8
	ghost.collision_mask = 1
	ghost.add_to_group("ghosts")

	# Positionner et ajouter
	position_ghost(ghost)
	add_ghost_to_scene(ghost)

func position_ghost(ghost: Node2D):
	"""Positionner un fantôme"""
	if maze:
		var ghost_spawns = maze.get_ghost_spawn_positions()
		if ghost_spawns.size() > 0:
			ghost.global_position = ghost_spawns[0]
			print("👻 Fantôme positionné à: ", ghost_spawns[0])
		else:
			ghost.global_position = Vector2(300, 300)
			print("👻 Fantôme positionné par défaut à: ", Vector2(300, 300))
	else:
		ghost.global_position = Vector2(400, 300)
		print("👻 Fantôme positionné sans maze à: ", Vector2(400, 300))

func add_ghost_to_scene(ghost: Node2D):
	"""Ajouter un fantôme à la scène avec gestion d'erreur"""
	var game_area = get_node_or_null("MainContainer")
	if game_area:
		var hbox = game_area.get_child(0) if game_area.get_child_count() > 0 else null
		var center_container = hbox.get_child(1) if hbox and hbox.get_child_count() > 1 else null
		if center_container:
			center_container.add_child(ghost)
			print("✅ Fantôme ajouté dans la zone de jeu")
			return

	# Fallback : ajouter directement
	add_child(ghost)
	print("✅ Fantôme ajouté en fallback")
