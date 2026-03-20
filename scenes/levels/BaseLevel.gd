# BaseLevel.gd
# Classe de base pour tous les niveaux - adaptée du code Game.gd existant
extends Control
class_name BaseLevel

signal level_completed()
signal player_died()
signal game_over()

@export var level_number: int = 1

# Références aux objets du jeu (comme dans Game.gd)
var maze: Node2D
var player: CharacterBody2D
var ui_container: Control
var score_label: Label
var lives_label: Label
var level_label: Label
var collectibles_label: Label

# Variables de jeu
var score: int = 0
var lives: int = 3
var collectibles_remaining: int = 0
var dots_remaining: int = 0
var pellets_remaining: int = 0

func _ready():
	print("🎮 Niveau ", level_number, " initialisé")

	# Récupérer les données du SceneManager
	var scene_manager = get_node("/root/SceneManager")
	if scene_manager:
		score = scene_manager.get_player_score()
		lives = scene_manager.get_player_lives()

	# Configuration de base
	setup_ui()
	setup_level()

	print("✅ Niveau ", level_number, " prêt")

func setup_ui():
	"""Créer l'interface utilisateur (basée sur Game.gd)"""
	# Container principal responsive
	var main_container = HBoxContainer.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(main_container)

	# Panneau UI à gauche
	var ui_panel = PanelContainer.new()
	ui_panel.custom_minimum_size = Vector2(300, 0)
	main_container.add_child(ui_panel)

	var ui_content = VBoxContainer.new()
	ui_panel.add_child(ui_content)

	# Informations de jeu
	var game_info = VBoxContainer.new()
	ui_content.add_child(game_info)

	score_label = Label.new()
	score_label.text = "SCORE: " + str(score)
	score_label.add_theme_font_size_override("font_size", 24)
	score_label.add_theme_color_override("font_color", Color.YELLOW)
	game_info.add_child(score_label)

	lives_label = Label.new()
	lives_label.text = "VIES: " + str(lives)
	lives_label.add_theme_font_size_override("font_size", 20)
	lives_label.add_theme_color_override("font_color", Color.RED)
	game_info.add_child(lives_label)

	level_label = Label.new()
	level_label.text = "NIVEAU: " + str(level_number)
	level_label.add_theme_font_size_override("font_size", 18)
	level_label.add_theme_color_override("font_color", Color.GREEN)
	game_info.add_child(level_label)

	collectibles_label = Label.new()
	collectibles_label.text = "Restants: 0"
	collectibles_label.add_theme_font_size_override("font_size", 16)
	collectibles_label.add_theme_color_override("font_color", Color.CYAN)
	game_info.add_child(collectibles_label)

	# Zone de jeu à droite
	var game_area = CenterContainer.new()
	game_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_container.add_child(game_area)

	# C'est ici que le maze sera ajouté
	ui_container = game_area

func setup_level():
	"""Configuration spécifique du niveau - à surcharger dans les sous-classes"""
	print("⚠️ setup_level() doit être surchargé dans la classe du niveau")

func update_ui():
	"""Mettre à jour l'interface utilisateur"""
	if score_label:
		score_label.text = "SCORE: " + str(score)
	if lives_label:
		lives_label.text = "VIES: " + str(lives)
	if level_label:
		level_label.text = "NIVEAU: " + str(level_number)
	if collectibles_label:
		collectibles_label.text = "Restants: " + str(collectibles_remaining)

func on_collectible_collected(points: int):
	"""Gestionnaire pour la collecte d'objets"""
	var scene_manager = get_node("/root/SceneManager")
	if scene_manager:
		scene_manager.add_score(points)
		score = scene_manager.get_player_score()

	collectibles_remaining -= 1
	update_ui()

	print("🎯 Collectibles restants: ", collectibles_remaining)

	if collectibles_remaining <= 0:
		print("🏆 Niveau terminé!")
		level_completed.emit()

func on_player_hit_ghost():
	"""Gestionnaire pour collision avec fantôme"""
	lives -= 1
	update_ui()

	print("💀 Joueur touché! Vies restantes: ", lives)

	if lives <= 0:
		print("💀 Game Over!")
		game_over.emit()
	else:
		player_died.emit()

func _input(event):
	"""Gestion des raccourcis clavier"""
	if event.is_action_pressed("ui_cancel"):
		# Retour au menu avec Échap
		var scene_manager = get_node("/root/SceneManager")
		if scene_manager:
			scene_manager.return_to_menu()
	elif event.is_action_pressed("restart_level"):
		# Redémarrer le niveau avec R
		var scene_manager = get_node("/root/SceneManager")
		if scene_manager:
			scene_manager.restart_current_level()