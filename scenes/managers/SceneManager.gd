# SceneManager.gd
# ═══════════════════════════════════════════════════════════════════════════════
# GESTIONNAIRE DE SCÈNES - RESPONSABILITÉ UNIQUE
# ═══════════════════════════════════════════════════════════════════════════════
#
# Ce script gère UNIQUEMENT les transitions entre les scènes du jeu.
# Il ne s'occupe PAS de la logique de jeu (score, vies, niveaux).
# Toute la logique métier est déléguée au GameManager.
#
# RESPONSABILITÉ :
# - Charger et décharger les scènes
# - Gérer les transitions propres
# - Mapper les types de scènes vers les fichiers .tscn
# - Émettre des événements de changement de scène
#
# UTILISATION :
# - SceneManager.change_scene(SceneType.MAIN_MENU)
# - SceneManager.change_scene_by_path("res://scenes/CustomScene.tscn")
# ═══════════════════════════════════════════════════════════════════════════════

extends Node

# ═══ SIGNAUX ÉMIS PAR LE SCENE MANAGER ═══
# Signaux purement techniques liés aux changements de scènes
signal scene_changed(scene_name: String)           # Émis après changement réussi
signal scene_change_started(scene_name: String)    # Émis avant le changement
signal scene_change_failed(scene_path: String)     # Émis en cas d'échec

# ═══ ÉNUMÉRATION DES TYPES DE SCÈNES ═══
# Catalogue de toutes les scènes disponibles dans le jeu
enum SceneType {
	MAIN_MENU,    # 0 - Menu principal
	GAME_LEVEL,   # 1 - Scène de jeu générique
	SETTINGS,     # 2 - Écran de paramètres (futur)
	CREDITS       # 3 - Écran de crédits (futur)
}

# ═══ MAPPING SCÈNES → FICHIERS .TSCN ═══
# Association entre types de scènes et fichiers physiques
# PRINCIPE : Un type de scène = Un fichier .tscn
const SCENE_PATHS = {
	SceneType.MAIN_MENU: "res://scenes/ui/MainMenu.tscn",
	SceneType.GAME_LEVEL: "res://scenes/core/Game.tscn",  # Utilise Game.tscn (version complète)
	SceneType.SETTINGS: "res://scenes/Settings.tscn",    # Futur
	SceneType.CREDITS: "res://scenes/Credits.tscn"       # Futur
}

# ═══ VARIABLES D'ÉTAT DU SCENE MANAGER ═══
var current_scene: Node = null                      # Référence vers la scène active
var current_scene_type: SceneType = SceneType.MAIN_MENU  # Type de scène actuelle
var is_changing_scene: bool = false                 # Flag pour éviter les changements concurrents

# ═══════════════════════════════════════════════════════════════════════════════
# INITIALISATION DU SCENE MANAGER
# ═══════════════════════════════════════════════════════════════════════════════
func _ready():
	"""
	INITIALISATION DU GESTIONNAIRE DE SCÈNES

	Configure le SceneManager et charge la scène initiale.
	Le SceneManager démarre toujours par le menu principal.
	"""
	print("🎬 SceneManager initialisé - Gestion des scènes uniquement")

	# Charger le menu principal comme scène de démarrage
	change_scene(SceneType.MAIN_MENU)

# ═══════════════════════════════════════════════════════════════════════════════
# FONCTION PRINCIPALE DE CHANGEMENT DE SCÈNE
# ═══════════════════════════════════════════════════════════════════════════════
func change_scene(scene_type: SceneType):
	"""
	CHANGEMENT DE SCÈNE PAR TYPE

	Charge une nouvelle scène basée sur son type énuméré.
	Cette fonction garantit une transition propre et sécurisée.

	PARAMÈTRES :
	- scene_type (SceneType) : Type de scène à charger

	PROCESSUS :
	1. Vérification anti-concurrence
	2. Récupération du chemin de fichier
	3. Appel de la fonction de changement générique
	"""
	print("🎯 Demande de changement vers: ", SceneType.keys()[scene_type])

	# Vérifier qu'un changement n'est pas déjà en cours
	if is_changing_scene:
		print("⚠️ Changement de scène déjà en cours - Demande ignorée")
		return

	# Récupérer le chemin de fichier correspondant
	if scene_type in SCENE_PATHS:
		var scene_path = SCENE_PATHS[scene_type]
		change_scene_by_path(scene_path, scene_type)
	else:
		print("❌ Type de scène inconnu: ", scene_type)
		scene_change_failed.emit("Type de scène invalide")

func change_scene_by_path(scene_path: String, scene_type: SceneType = SceneType.MAIN_MENU):
	"""
	CHANGEMENT DE SCÈNE PAR CHEMIN DE FICHIER

	Fonction générique qui effectue le changement de scène proprement dit.
	Gère tout le processus de déchargement/rechargement.

	PARAMÈTRES :
	- scene_path (String) : Chemin vers le fichier .tscn
	- scene_type (SceneType) : Type de scène (pour le suivi d'état)

	PHASES :
	1. Préparation et signalisation
	2. Nettoyage de l'ancienne scène
	3. Chargement de la nouvelle scène
	4. Intégration et finalisation
	"""
	print("🔄 === DÉBUT CHANGEMENT DE SCÈNE ===")
	print("📁 Fichier cible: ", scene_path)

	# ═══ PHASE 1 : PRÉPARATION ═══
	is_changing_scene = true
	scene_change_started.emit(SceneType.keys()[scene_type])

	# ═══ PHASE 2 : NETTOYAGE DE L'ANCIENNE SCÈNE ═══
	await _cleanup_current_scene()

	# ═══ PHASE 3 : CHARGEMENT DE LA NOUVELLE SCÈNE ═══
	var success = _load_new_scene(scene_path)

	if success:
		# ═══ PHASE 4 : FINALISATION RÉUSSIE ═══
		current_scene_type = scene_type
		is_changing_scene = false
		scene_changed.emit(SceneType.keys()[scene_type])
		print("✅ === CHANGEMENT DE SCÈNE RÉUSSI ===")
	else:
		# ═══ PHASE 4 : GESTION D'ÉCHEC ═══
		is_changing_scene = false
		scene_change_failed.emit(scene_path)
		print("❌ === ÉCHEC DU CHANGEMENT DE SCÈNE ===")

# ═══════════════════════════════════════════════════════════════════════════════
# FONCTIONS UTILITAIRES PRIVÉES
# ═══════════════════════════════════════════════════════════════════════════════

func _cleanup_current_scene():
	"""
	NETTOYAGE PROPRE DE LA SCÈNE ACTUELLE

	Supprime la scène actuelle de manière sécurisée pour éviter
	les fuites mémoire et les références dangereuses.
	"""
	if current_scene:
		print("🧹 Suppression de l'ancienne scène...")
		current_scene.queue_free()
		await current_scene.tree_exited
		current_scene = null
		print("✅ Ancienne scène supprimée")

func _load_new_scene(scene_path: String) -> bool:
	"""
	CHARGEMENT D'UNE NOUVELLE SCÈNE

	Charge un fichier .tscn depuis le disque et l'intègre à l'arbre de scène.

	PARAMÈTRES :
	- scene_path (String) : Chemin vers le fichier .tscn

	RETOUR :
	- bool : true si le chargement a réussi, false sinon
	"""
	print("📦 Chargement de: ", scene_path)

	# Vérifier l'existence du fichier
	if not ResourceLoader.exists(scene_path):
		print("❌ Fichier introuvable: ", scene_path)
		return false

	# Charger la ressource
	var scene_resource = load(scene_path)
	if not scene_resource:
		print("❌ Impossible de charger la ressource: ", scene_path)
		return false

	# Instancier la scène
	current_scene = scene_resource.instantiate()
	if not current_scene:
		print("❌ Impossible d'instancier la scène: ", scene_path)
		return false

	# Ajouter à l'arbre de scène
	get_tree().root.call_deferred("add_child", current_scene)

	print("✅ Nouvelle scène chargée et ajoutée")
	return true

# ═══════════════════════════════════════════════════════════════════════════════
# FONCTIONS D'ACCÈS EN LECTURE SEULE
# ═══════════════════════════════════════════════════════════════════════════════

func get_current_scene() -> Node:
	"""
	RÉCUPÉRATION DE LA SCÈNE ACTUELLE

	Permet aux autres scripts d'accéder à la scène active
	sans pouvoir la modifier directement.

	RETOUR :
	- Node : Référence vers la scène actuelle (peut être null)
	"""
	return current_scene

func get_current_scene_type() -> SceneType:
	"""
	RÉCUPÉRATION DU TYPE DE SCÈNE ACTUELLE

	Permet de connaître le type de la scène actuellement chargée.

	RETOUR :
	- SceneType : Type énuméré de la scène actuelle
	"""
	return current_scene_type

func is_scene_changing() -> bool:
	"""
	VÉRIFICATION D'UN CHANGEMENT EN COURS

	Permet de savoir si un changement de scène est actuellement en cours.
	Utile pour éviter les actions concurrentes.

	RETOUR :
	- bool : true si un changement est en cours, false sinon
	"""
	return is_changing_scene

# ═══════════════════════════════════════════════════════════════════════════════
# FONCTIONS DE CONVENANCE POUR LES SCÈNES COMMUNES
# ═══════════════════════════════════════════════════════════════════════════════

func goto_main_menu():
	"""RACCOURCI : Aller au menu principal"""
	change_scene(SceneType.MAIN_MENU)

func goto_game():
	"""RACCOURCI : Aller à la scène de jeu"""
	change_scene(SceneType.GAME_LEVEL)

func go_to_level(level: int):
	"""RACCOURCI : Aller à un niveau spécifique en mode debug"""
	print("\n=== GO_TO_LEVEL APPELÉ ===")
	print("🎮 Chargement du niveau ", level, " en mode debug")
	# Stocker le niveau demandé pour que la scène de jeu puisse le lire
	set_meta("requested_level", level)
	print("💾 Meta 'requested_level' défini à: ", get_meta("requested_level"))
	print("➡️ Appel de change_scene(GAME_LEVEL)")
	change_scene(SceneType.GAME_LEVEL)
	print("=== FIN GO_TO_LEVEL ===")

func goto_settings():
	"""RACCOURCI : Aller aux paramètres (futur)"""
	change_scene(SceneType.SETTINGS)

func goto_credits():
	"""RACCOURCI : Aller aux crédits (futur)"""
	change_scene(SceneType.CREDITS)