# MainMenu.gd
# Menu principal du jeu avec gestion des scènes
extends Control

@onready var scene_manager: Node

func _ready():
	print("🏠 Menu principal chargé")
	if AbilityManager and AbilityManager.has_method("reset_run"):
		AbilityManager.reset_run()
	# Récupérer le SceneManager depuis l'autoload
	scene_manager = get_node("/root/SceneManager") if get_node_or_null("/root/SceneManager") else null

	# Connecter les boutons de la scène
	var start_button = get_node_or_null("VBoxContainer/StartButton")
	if start_button:
		start_button.pressed.connect(_on_play_pressed)
		print("✅ Bouton START GAME connecté")

	var debug_button = get_node_or_null("VBoxContainer/DebugButton")
	if debug_button:
		debug_button.pressed.connect(_on_debug_pressed)
		print("✅ Bouton DEBUG NIVEAUX connecté")

	var quit_button = get_node_or_null("VBoxContainer/QuitButton")
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
		print("✅ Bouton QUITTER connecté")

	# Ne plus créer de menu dynamique - utiliser celui de la scène
	# setup_ui()  # DÉSACTIVÉ

func setup_ui():
	# Créer l'interface du menu principal
	var main_container = VBoxContainer.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(main_container)

	# Titre du jeu
	var title = Label.new()
	title.text = "PACMAN ROGUELITE"
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color.YELLOW)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_container.add_child(title)

	# Espace
	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(0, 50)
	main_container.add_child(spacer1)

	# Bouton Jouer
	var play_button = Button.new()
	play_button.text = "JOUER"
	play_button.custom_minimum_size = Vector2(200, 50)
	play_button.pressed.connect(_on_play_pressed)
	main_container.add_child(play_button)

	# Espace
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 20)
	main_container.add_child(spacer2)

	# Bouton Debug Niveaux
	var debug_button = Button.new()
	debug_button.text = "DEBUG NIVEAUX"
	debug_button.custom_minimum_size = Vector2(200, 50)
	debug_button.pressed.connect(_on_debug_pressed)
	main_container.add_child(debug_button)

	# Espace
	var spacer3 = Control.new()
	spacer3.custom_minimum_size = Vector2(0, 20)
	main_container.add_child(spacer3)

	# Bouton Quitter
	var quit_button = Button.new()
	quit_button.text = "QUITTER"
	quit_button.custom_minimum_size = Vector2(200, 50)
	quit_button.pressed.connect(_on_quit_pressed)
	main_container.add_child(quit_button)

	print("🏠 Interface du menu créée")

func _on_play_pressed():
	print("🎮 Démarrage du jeu demandé")
	if scene_manager:
		scene_manager.change_scene(scene_manager.SceneType.GAME_LEVEL)

func _on_debug_pressed():
	print("🔧 Mode debug demandé")

	# Vérifier si un menu de debug existe déjà dans la scène
	var existing_debug_menu = get_node_or_null("DebugMenuPanel")
	if existing_debug_menu:
		print("✅ Menu de debug trouvé dans la scène, affichage...")
		existing_debug_menu.visible = true
		return

	show_debug_menu()

func _on_quit_pressed():
	print("👋 Fermeture du jeu")
	get_tree().quit()

func show_debug_menu():
	print("🔧 Création du menu de debug...")

	# Créer un Control centré simple
	var debug_container = Control.new()
	debug_container.name = "DebugContainer"
	debug_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(debug_container)

	# Panel centré
	var center_container = CenterContainer.new()
	center_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	debug_container.add_child(center_container)

	var debug_panel = PanelContainer.new()
	debug_panel.custom_minimum_size = Vector2(300, 350)
	center_container.add_child(debug_panel)

	# VBox pour le contenu
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	debug_panel.add_child(vbox)

	# Ajouter des marges
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	vbox.add_child(margin)

	var inner_vbox = VBoxContainer.new()
	inner_vbox.add_theme_constant_override("separation", 10)
	margin.add_child(inner_vbox)

	# Titre
	var title = Label.new()
	title.text = "🔧 DEBUG LEVELS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	inner_vbox.add_child(title)

	# Grille de boutons
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	inner_vbox.add_child(grid)

	# Créer 4 boutons de niveau
	for i in range(1, 5):
		var btn = Button.new()
		btn.text = "LV " + str(i)
		btn.custom_minimum_size = Vector2(100, 50)
		var level = i
		btn.pressed.connect(func():
			print("🎯 Level ", level, " clicked!")
			if scene_manager:
				scene_manager.go_to_level(level)
			else:
				print("No scene manager")
			debug_container.queue_free()
		)
		grid.add_child(btn)

	# Bouton Reset
	var reset_btn = Button.new()
	reset_btn.text = "🔄 RESET"
	reset_btn.custom_minimum_size = Vector2(0, 40)
	reset_btn.pressed.connect(func():
		print("🔄 Reset!")
		if scene_manager:
			scene_manager.goto_game()
		else:
			print("No scene manager")
		debug_container.queue_free()
	)
	inner_vbox.add_child(reset_btn)

	# Bouton Retour
	var back_btn = Button.new()
	back_btn.text = "🏠 RETOUR MENU"
	back_btn.custom_minimum_size = Vector2(0, 40)
	back_btn.pressed.connect(func():
		print("🏠 Fermeture menu debug")
		debug_container.queue_free()
	)
	inner_vbox.add_child(back_btn)

	print("✅ Menu de debug créé!")
func _on_debug_level_clicked(level: int, layer):
	print("\n=== DEBUG LEVEL CLICKED ===")
	print("🎯 Niveau ", level, " sélectionné en debug")
	print("Scene Manager existe: ", scene_manager != null)
	if scene_manager:
		print("➡️ Appel de go_to_level(", level, ")")
		scene_manager.go_to_level(level)
		layer.queue_free()
	else:
		print("❌ ERREUR: SceneManager est null!")
	print("=== FIN DEBUG ===")

func _on_debug_reset_clicked(layer):
	print("🔄 Reset demandé")
	if scene_manager:
		scene_manager.goto_game()
		layer.queue_free()

func _on_debug_level_selected(level: int):
	print("🎯 Niveau ", level, " sélectionné en debug")
	if scene_manager:
		scene_manager.go_to_level(level)

func _input(event):
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.keycode == KEY_SPACE):
		_on_play_pressed()
		get_viewport().set_input_as_handled()
