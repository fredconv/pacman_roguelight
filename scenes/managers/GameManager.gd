# GameManager.gd
# ═══════════════════════════════════════════════════════════════════════════════
# GESTIONNAIRE DE LOGIQUE DE JEU - RESPONSABILITÉ UNIQUE
# ═══════════════════════════════════════════════════════════════════════════════
#
# Ce script gère UNIQUEMENT la logique métier du jeu Pac-Man Roguelite.
# Il ne s'occupe PAS des changements de scènes (délégués au SceneManager).
#
# RESPONSABILITÉS :
# - Gestion du score du joueur
# - Gestion des vies du joueur
# - Gestion de la progression des niveaux
# - États de jeu (en cours, game over, victoire)
# - Communication avec les scènes de jeu via signaux
# - Persistance des données de jeu
#
# UTILISATION :
# - GameManager.start_new_game() → Initialise une nouvelle partie
# - GameManager.add_score(points) → Ajoute des points
# - GameManager.handle_player_death() → Gère la mort du joueur
# - GameManager.handle_level_completion() → Gère la fin d'un niveau
# ═══════════════════════════════════════════════════════════════════════════════

extends Node

# ═══ SIGNAUX ÉMIS PAR LE GAME MANAGER ═══
# Signaux liés à la logique de jeu et aux événements gameplay
signal game_started()                          # Nouvelle partie démarrée
signal score_changed(new_score: int)           # Score modifié
signal lives_changed(new_lives: int)           # Vies modifiées
signal level_changed(new_level: int)           # Niveau modifié
signal level_completed(level: int)             # Niveau terminé avec succès
signal player_died()                           # Joueur mort (perte d'une vie)
signal game_over()                             # Game over définitif
signal game_won()                              # Tous les niveaux terminés
signal game_state_changed(new_state: GameState) # Changement d'état global

# ═══ ÉNUMÉRATION DES ÉTATS DE JEU ═══
enum GameState {
	MENU,           # 0 - Dans les menus
	PLAYING,        # 1 - En train de jouer
	PAUSED,         # 2 - Jeu en pause
	GAME_OVER,      # 3 - Game over
	VICTORY,        # 4 - Victoire complète
	RESTARTING      # 5 - Redémarrage en cours
}

# ═══ CONFIGURATION DU JEU ═══
const MAX_LEVELS: int = 4               # Nombre total de niveaux dans le jeu
const DEFAULT_LIVES: int = 3            # Nombre de vies au début
const LEVEL_COMPLETE_BONUS: int = 1000  # Bonus de points pour finir un niveau

# ═══ DONNÉES PERSISTANTES DU JOUEUR ═══
# Ces données représentent l'état complet d'une partie
var player_score: int = 0               # Score total accumulé
var player_lives: int = DEFAULT_LIVES   # Vies restantes
var current_level: int = 1              # Niveau actuel (1-4)
var game_state: GameState = GameState.MENU  # État actuel du jeu

# ═══ STATISTIQUES DE SESSION ═══
# Données pour le suivi des performances du joueur
var session_start_time: float = 0.0    # Timestamp du début de partie
var levels_completed: int = 0           # Nombre de niveaux terminés
var total_deaths: int = 0               # Nombre total de morts

# ═══════════════════════════════════════════════════════════════════════════════
# INITIALISATION DU GAME MANAGER
# ═══════════════════════════════════════════════════════════════════════════════
func _ready():
	"""
	INITIALISATION DU GESTIONNAIRE DE JEU

	Configure le GameManager et établit les connexions nécessaires.
	Le GameManager démarre en état MENU et attend qu'une partie soit lancée.
	"""
	print("🎮 GameManager initialisé - Gestion de la logique de jeu")

	# Connecter aux signaux du SceneManager pour savoir quand on change de scène
	if SceneManager:
		SceneManager.scene_changed.connect(_on_scene_changed)
		print("🔗 Connexion établie avec SceneManager")

	# État initial
	set_game_state(GameState.MENU)
	print("📊 État initial: MENU")

# ═══════════════════════════════════════════════════════════════════════════════
# FONCTIONS DE GESTION DE PARTIE
# ═══════════════════════════════════════════════════════════════════════════════

func start_new_game():
	"""
	DÉMARRAGE D'UNE NOUVELLE PARTIE

	Initialise toutes les données pour une nouvelle session de jeu.
	Cette fonction remet tout à zéro et configure l'état initial.
	"""
	print("🚀 === DÉMARRAGE D'UNE NOUVELLE PARTIE ===")

	# ═══ RÉINITIALISATION DES DONNÉES DE JEU ═══
	player_score = 0
	player_lives = DEFAULT_LIVES
	current_level = 1
	levels_completed = 0
	total_deaths = 0

	# ═══ INITIALISATION DU TIMER DE SESSION ═══
	session_start_time = Time.get_time_dict_from_system().hour * 3600 + \
						 Time.get_time_dict_from_system().minute * 60 + \
						 Time.get_time_dict_from_system().second

	# ═══ CHANGEMENT D'ÉTAT ═══
	set_game_state(GameState.PLAYING)

	print("📊 Données initialisées - Score:", player_score, "Vies:", player_lives, "Niveau:", current_level)

	# ═══ ÉMISSION DES SIGNAUX ═══
	game_started.emit()
	score_changed.emit(player_score)
	lives_changed.emit(player_lives)
	level_changed.emit(current_level)

	# ═══ DEMANDE DE CHANGEMENT DE SCÈNE ═══
	print("🎬 Demande de chargement de la scène de jeu...")
	SceneManager.goto_game()

# ═══════════════════════════════════════════════════════════════════════════════
# FONCTIONS DE GESTION DU SCORE
# ═══════════════════════════════════════════════════════════════════════════════

func add_score(points: int):
	"""AJOUT DE POINTS AU SCORE"""
	var old_score = player_score
	player_score += points

	# Empêcher le score négatif
	if player_score < 0:
		player_score = 0

	print("🎯 Score: ", old_score, " → ", player_score, " (",
		  ("+"+str(points)) if points >= 0 else str(points), ")")

	score_changed.emit(player_score)

func get_player_score() -> int:
	"""GETTER : Score actuel du joueur"""
	return player_score

# ═══════════════════════════════════════════════════════════════════════════════
# FONCTIONS DE GESTION DES VIES
# ═══════════════════════════════════════════════════════════════════════════════

func handle_player_death():
	"""GESTION DE LA MORT DU JOUEUR"""
	print("💀 === MORT DU JOUEUR ===")

	total_deaths += 1
	player_lives -= 1

	print("📊 Morts totales:", total_deaths, "Vies restantes:", player_lives)

	player_died.emit()
	lives_changed.emit(player_lives)

	if player_lives > 0:
		print("❤️ Vies restantes - Possibilité de continuer")
	else:
		print("💥 Plus de vies - Game Over imminent")
		trigger_game_over()

func get_player_lives() -> int:
	"""GETTER : Vies restantes du joueur"""
	return player_lives

func add_life():
	"""AJOUT D'UNE VIE BONUS"""
	player_lives += 1
	print("❤️ Vie bonus accordée ! Vies totales: ", player_lives)
	lives_changed.emit(player_lives)

# ═══════════════════════════════════════════════════════════════════════════════
# FONCTIONS DE GESTION DES NIVEAUX
# ═══════════════════════════════════════════════════════════════════════════════

func handle_level_completion():
	"""GESTION DE LA COMPLÉTION D'UN NIVEAU"""
	print("🎉 === NIVEAU TERMINÉ AVEC SUCCÈS ===")
	print("📈 Niveau complété: ", current_level)

	levels_completed += 1

	print("🎁 Bonus de niveau: +", LEVEL_COMPLETE_BONUS)
	add_score(LEVEL_COMPLETE_BONUS)

	level_completed.emit(current_level)

	if current_level >= MAX_LEVELS:
		print("🏆 TOUS LES NIVEAUX TERMINÉS ! VICTOIRE !")
		trigger_game_won()
	else:
		current_level += 1
		print("⬆️ Progression vers le niveau ", current_level)
		level_changed.emit(current_level)

func get_current_level() -> int:
	"""GETTER : Niveau actuel"""
	return current_level

func set_level(level: int):
	"""DÉFINITION FORCÉE DU NIVEAU (DEBUG)"""
	if level >= 1 and level <= MAX_LEVELS:
		current_level = level
		print("🎯 Niveau forcé à: ", current_level)
		level_changed.emit(current_level)
	else:
		print("❌ Niveau invalide: ", level, " (valides: 1-", MAX_LEVELS, ")")

# ═══════════════════════════════════════════════════════════════════════════════
# FONCTIONS DE GESTION D'ÉTAT DE JEU
# ═══════════════════════════════════════════════════════════════════════════════

func trigger_game_over():
	"""DÉCLENCHEMENT DU GAME OVER"""
	print("💀 === GAME OVER DÉFINITIF ===")
	print("📊 Score final:", player_score, "Niveau atteint:", current_level)
	print("   Niveaux complétés:", levels_completed, "Morts totales:", total_deaths)

	set_game_state(GameState.GAME_OVER)
	game_over.emit()

	print("🏠 Retour au menu dans 3 secondes...")
	await get_tree().create_timer(3.0).timeout
	return_to_menu()

func trigger_game_won():
	"""DÉCLENCHEMENT DE LA VICTOIRE"""
	print("🏆 === VICTOIRE COMPLÈTE ! ===")
	print("🎊 Tous les niveaux ont été terminés avec succès !")

	var victory_bonus = player_lives * 500
	print("🎁 Bonus de victoire: +", victory_bonus, " (vies restantes)")
	add_score(victory_bonus)

	set_game_state(GameState.VICTORY)
	game_won.emit()

	print("🏠 Retour au menu dans 5 secondes...")
	await get_tree().create_timer(5.0).timeout
	return_to_menu()

func pause_game():
	"""MISE EN PAUSE DU JEU"""
	if game_state == GameState.PLAYING:
		set_game_state(GameState.PAUSED)
		print("⏸️ Jeu mis en pause")

func resume_game():
	"""REPRISE DU JEU"""
	if game_state == GameState.PAUSED:
		set_game_state(GameState.PLAYING)
		print("▶️ Jeu repris")

func return_to_menu():
	"""RETOUR AU MENU PRINCIPAL"""
	print("🏠 Retour au menu principal")
	set_game_state(GameState.MENU)
	SceneManager.goto_main_menu()

func set_game_state(new_state: GameState) -> void:
	"""Définit l'état global et applique ses effets runtime."""
	if game_state == new_state:
		return
	game_state = new_state
	_apply_runtime_state(new_state)
	game_state_changed.emit(new_state)
	print("📊 État de jeu -> ", get_game_state_name(new_state))

func start_playing() -> void:
	set_game_state(GameState.PLAYING)

func on_player_died() -> void:
	set_game_state(GameState.GAME_OVER)

func begin_restart() -> void:
	set_game_state(GameState.RESTARTING)

func finish_restart() -> void:
	set_game_state(GameState.PLAYING)

func get_game_state_name(state: GameState = game_state) -> String:
	return GameState.keys()[state]

func _apply_runtime_state(state: GameState) -> void:
	# On gèle le gameplay via time_scale pour garder l'UI/input disponibles.
	match state:
		GameState.PLAYING, GameState.MENU:
			Engine.time_scale = 1.0
		GameState.PAUSED, GameState.GAME_OVER, GameState.VICTORY, GameState.RESTARTING:
			Engine.time_scale = 0.0

# ═══════════════════════════════════════════════════════════════════════════════
# GETTERS D'ÉTAT
# ═══════════════════════════════════════════════════════════════════════════════

func get_game_state() -> GameState:
	"""GETTER : État actuel du jeu"""
	return game_state

func is_playing() -> bool:
	"""VÉRIFICATION : Le jeu est-il en cours ?"""
	return game_state == GameState.PLAYING

func is_paused() -> bool:
	"""VÉRIFICATION : Le jeu est-il en pause ?"""
	return game_state == GameState.PAUSED

func is_game_over() -> bool:
	"""VÉRIFICATION : Le jeu est-il en game over ?"""
	return game_state == GameState.GAME_OVER

# ═══════════════════════════════════════════════════════════════════════════════
# GESTIONNAIRES DE SIGNAUX EXTERNES
# ═══════════════════════════════════════════════════════════════════════════════

func _on_scene_changed(scene_name: String):
	"""GESTIONNAIRE : Changement de scène détecté"""
	print("🎬 Scène changée vers: ", scene_name)

	if scene_name == "MAIN_MENU":
		if game_state != GameState.MENU:
			set_game_state(GameState.MENU)
			print("📊 État mis à jour: MENU")
	elif scene_name == "GAME_LEVEL":
		if game_state == GameState.MENU:
			print("📊 Passage automatique en mode PLAYING")
			set_game_state(GameState.PLAYING)
