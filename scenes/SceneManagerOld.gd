# SceneManager.gd
# ═══════════════════════════════════════════════════════════════════════════════
# GESTIONNAIRE PRINCIPAL DES SCÈNES DU JEU PAC-MAN ROGUELITE
# ═══════════════════════════════════════════════════════════════════════════════
#
# Ce script gère toutes les transitions entre les différentes scènes du jeu :
# - Menu principal
# - Niveaux de jeu (1 à 4)
# - Gestion des données persistantes (score, vies, level)
# - Connexion automatique des signaux entre scènes
#
# UTILISATION :
# - SceneManager.start_game() → Démarre une nouvelle partie
# - SceneManager.go_to_next_level() → Niveau suivant
# - SceneManager.return_to_menu() → Retour menu
# ═══════════════════════════════════════════════════════════════════════════════

extends Node

# ═══ SIGNAUX ÉMIS PAR LE SCENE MANAGER ═══
# Permettent aux autres scripts d'écouter les changements d'état du jeu
signal scene_changed(scene_name: String)    # Émis quand une scène change
signal level_completed(level_number: int)   # Émis quand un niveau est terminé
signal game_over()                          # Émis en cas de game over

# ═══ ÉNUMÉRATION DES TYPES DE SCÈNES ═══
# Définit tous les types de scènes disponibles dans le jeu
# Utilisé comme index sécurisé pour éviter les erreurs de typage
enum SceneType {
	MAIN_MENU,    # 0 - Écran d'accueil
	LEVEL_1,      # 1 - Premier niveau
	LEVEL_2,      # 2 - Deuxième niveau
	LEVEL_3,      # 3 - Troisième niveau
	LEVEL_4       # 4 - Quatrième niveau
}

# ═══ MAPPING DES SCÈNES VERS LEURS FICHIERS .TSCN ═══
# Dictionnaire qui associe chaque type de scène à son fichier Godot
# IMPORTANT : Tous les niveaux utilisent GameSimple.tscn pour l'instant
# car c'est la version qui fonctionne correctement
const SCENE_PATHS = {
	SceneType.MAIN_MENU: "res://scenes/MainMenu.tscn",      # Menu principal
	SceneType.LEVEL_1: "res://scenes/GameSimple.tscn",      # Niveau 1
	SceneType.LEVEL_2: "res://scenes/GameSimple.tscn",      # Niveau 2 (même scène)
	SceneType.LEVEL_3: "res://scenes/GameSimple.tscn",      # Niveau 3 (même scène)
	SceneType.LEVEL_4: "res://scenes/GameSimple.tscn"       # Niveau 4 (même scène)
}

# ═══ VARIABLES D'ÉTAT POUR LE SUIVI DE LA SCÈNE ACTUELLE ═══
var current_scene: Node = null                        # Référence vers la scène actuellement chargée
var current_scene_type: SceneType = SceneType.MAIN_MENU  # Type de la scène actuelle

# ═══ DONNÉES PERSISTANTES DU JOUEUR ═══
# Ces données survivent aux changements de scènes et permettent
# de maintenir la progression du joueur à travers les niveaux
var player_score: int = 0      # Score total accumulé du joueur
var player_lives: int = 3      # Nombre de vies restantes
var current_level: int = 1     # Niveau actuel (1-4)

# ═══════════════════════════════════════════════════════════════════════════════
# FONCTION D'INITIALISATION DU SCENE MANAGER
# ═══════════════════════════════════════════════════════════════════════════════
func _ready():
	"""
	FONCTION D'INITIALISATION AUTOMATIQUE DE GODOT

	Appelée automatiquement quand le SceneManager est ajouté à l'arbre de scène.
	Puisque SceneManager est configuré en AutoLoad dans project.godot,
	cette fonction s'exécute au démarrage du jeu.

	ACTIONS EFFECTUÉES :
	1. Affiche un message de debug pour confirmer l'initialisation
	2. Charge automatiquement le menu principal comme première scène

	POURQUOI COMMENCER PAR LE MENU :
	- Permet au joueur de choisir de démarrer une partie
	- Évite de lancer directement un niveau
	- Interface standard pour tous les jeux
	"""
	print("🎮 SceneManager initialisé - Système de gestion des scènes opérationnel")

	# Charger le menu principal comme scène de démarrage
	# Ceci sera la première chose que verra le joueur
	change_scene(SceneType.MAIN_MENU)

# ═══════════════════════════════════════════════════════════════════════════════
# FONCTION CENTRALE DE CHANGEMENT DE SCÈNE
# ═══════════════════════════════════════════════════════════════════════════════
func change_scene(scene_type: SceneType):
	"""
	FONCTION MAÎTRESSE POUR CHANGER DE SCÈNE

	Cette fonction gère toute la logique de transition entre les scènes :
	1. Nettoyage de l'ancienne scène
	2. Chargement de la nouvelle scène
	3. Connexion automatique des signaux
	4. Mise à jour des variables d'état

	PARAMÈTRES :
	- scene_type (SceneType) : Type de scène à charger (MAIN_MENU, LEVEL_1, etc.)

	PROCESSUS DÉTAILLÉ :
	Phase 1 - Nettoyage : Supprime proprement l'ancienne scène
	Phase 2 - Chargement : Charge le fichier .tscn depuis le disque
	Phase 3 - Instanciation : Crée une instance de la scène en mémoire
	Phase 4 - Intégration : Ajoute la scène à l'arbre et connecte les signaux
	Phase 5 - Notification : Émet un signal pour prévenir les autres systèmes

	GESTION D'ERREURS :
	- Vérifie que le fichier .tscn existe et peut être chargé
	- Utilise call_deferred pour éviter les conflits de threading Godot
	- Logs détaillés pour diagnostiquer les problèmes
	"""
	print("🔄 === DÉBUT CHANGEMENT DE SCÈNE ===")
	print("🎯 Scène cible: ", SceneType.keys()[scene_type])

	# ═══ PHASE 1 : NETTOYAGE DE L'ANCIENNE SCÈNE ═══
	# Il faut supprimer proprement l'ancienne scène pour éviter les fuites mémoire
	if current_scene:
		print("🧹 Suppression de l'ancienne scène...")
		current_scene.queue_free()  # Marque pour suppression à la fin du frame
		await current_scene.tree_exited  # Attend que la suppression soit effective
		print("✅ Ancienne scène supprimée")

	# ═══ PHASE 2 : CHARGEMENT DE LA NOUVELLE SCÈNE ═══
	# Récupère le chemin du fichier .tscn depuis notre dictionnaire
	var scene_path = SCENE_PATHS[scene_type]
	print("📁 Chargement du fichier: ", scene_path)

	# Charge la ressource .tscn depuis le disque
	# IMPORTANT : load() est synchrone et peut bloquer si le fichier est gros
	var new_scene_resource = load(scene_path)
	print("📦 Ressource chargée: ", new_scene_resource != null)

	# ═══ PHASE 3 : VÉRIFICATION ET INSTANCIATION ═══
	if new_scene_resource:
		print("🏗️ Instanciation de la nouvelle scène...")

		# Crée une instance de la scène (transforme le .tscn en obets Node)
		current_scene = new_scene_resource.instantiate()

		# ═══ PHASE 4 : INTÉGRATION À L'ARBRE DE SCÈNE ═══
		# ATTENTION : Utilisation de call_deferred pour éviter l'erreur "parent busy"
		# Cela reporte l'ajout à la fin du frame actuel
		get_tree().root.call_deferred("add_child", current_scene)

		# Met à jour notre variable d'état
		current_scene_type = scene_type

		# ═══ PHASE 5 : CONNEXION DES SIGNAUX (SI NIVEAU DE JEU) ═══
		# Les niveaux de jeu ont des signaux spéciaux (level_completed, player_died)
		# Le menu principal n'en a pas besoin
		if scene_type != SceneType.MAIN_MENU:
			print("🔗 Programmation de la connexion des signaux...")
			call_deferred("connect_level_signals")  # Reporte après l'ajout à l'arbre

		# ═══ PHASE 6 : NOTIFICATION DU CHANGEMENT ═══
		# Émet un signal pour prévenir les autres systèmes du changement
		scene_changed.emit(SceneType.keys()[scene_type])
		print("✅ === CHANGEMENT DE SCÈNE RÉUSSI ===")
		print("🎮 Scène active: ", scene_path)
	else:
		# ═══ GESTION D'ERREUR ═══
		print("❌ === ÉCHEC DU CHANGEMENT DE SCÈNE ===")
		print("💥 Impossible de charger: ", scene_path)
		print("🔍 Vérifiez que le fichier existe et n'est pas corrompu")

# ═══════════════════════════════════════════════════════════════════════════════
# CONNEXION AUTOMATIQUE DES SIGNAUX DE NIVEAU
# ═══════════════════════════════════════════════════════════════════════════════
func connect_level_signals():
	"""
	CONNEXION AUTOMATIQUE DES SIGNAUX ENTRE LE NIVEAU ET LE SCENE MANAGER

	Cette fonction établit la communication entre la scène de niveau chargée
	et le SceneManager pour gérer automatiquement les événements de jeu.

	SIGNAUX CONNECTÉS :
	1. level_completed → _on_level_completed : Quand le joueur termine le niveau
	2. player_died → _on_player_died : Quand le joueur perd une vie
	3. game_over → _on_game_over : Quand le joueur n'a plus de vies

	POURQUOI CETTE FONCTION EST NÉCESSAIRE :
	- Les scènes de niveau sont chargées dynamiquement
	- Chaque nouvelle instance de niveau doit être reconnectée
	- Permet une communication bidirectionnelle niveau ↔ manager

	SÉCURITÉ :
	- Vérifie l'existence de chaque signal avant connexion
	- Évite les erreurs si la scène n'a pas tous les signaux
	- Utilise has_signal() pour une vérification propre

	ORDRE D'EXÉCUTION :
	Cette fonction est appelée via call_deferred() depuis change_scene()
	pour s'assurer que la scène est complètement ajoutée à l'arbre
	"""
	print("🔗 === CONNEXION DES SIGNAUX DE NIVEAU ===")

	# Vérification de sécurité : s'assurer qu'on a bien une scène chargée
	if not current_scene:
		print("❌ Aucune scène actuelle à connecter")
		return

	# ═══ CONNEXION DU SIGNAL DE NIVEAU TERMINÉ ═══
	# Émis par la scène de niveau quand le joueur collecte tous les dots
	if current_scene.has_signal("level_completed"):
		current_scene.level_completed.connect(_on_level_completed)
		print("✅ Signal 'level_completed' connecté")
	else:
		print("⚠️ Signal 'level_completed' non disponible dans cette scène")

	# ═══ CONNEXION DU SIGNAL DE MORT DU JOUEUR ═══
	# Émis par la scène de niveau quand le joueur touche un fantôme
	if current_scene.has_signal("player_died"):
		current_scene.player_died.connect(_on_player_died)
		print("✅ Signal 'player_died' connecté")
	else:
		print("⚠️ Signal 'player_died' non disponible dans cette scène")

	# ═══ CONNEXION DU SIGNAL DE GAME OVER ═══
	# Émis par la scène de niveau en cas de game over définitif
	if current_scene.has_signal("game_over"):
		current_scene.game_over.connect(_on_game_over)
		print("✅ Signal 'game_over' connecté")
	else:
		print("⚠️ Signal 'game_over' non disponible dans cette scène")

	print("🔗 === CONNEXION DES SIGNAUX TERMINÉE ===")

# ═══════════════════════════════════════════════════════════════════════════════
# FONCTIONS DE NAVIGATION PRINCIPALE
# ═══════════════════════════════════════════════════════════════════════════════

func start_game():
	"""
	DÉMARRAGE D'UNE NOUVELLE PARTIE

	Cette fonction initialise une nouvelle session de jeu complète.
	Elle remet à zéro toutes les données persistantes et lance le premier niveau.

	ACTIONS EFFECTUÉES :
	1. Réinitialisation du score à 0
	2. Réinitialisation des vies à 3 (valeur par défaut)
	3. Définition du niveau actuel à 1 (premier niveau)
	4. Chargement de la scène du niveau 1

	UTILISATION TYPIQUE :
	- Appelée depuis le bouton "Nouvelle Partie" du menu principal
	- Appelée après un game over pour recommencer
	- Peut être appelée depuis le debug pour reset complet

	DONNÉES RÉINITIALISÉES :
	- player_score : Points accumulés remis à 0
	- player_lives : Vies remises à 3 (maximum standard)
	- current_level : Niveau remis à 1 (premier niveau)

	TRANSITION :
	Lance automatiquement le chargement du premier niveau via change_scene()
	"""
	print("🎮 === DÉMARRAGE D'UNE NOUVELLE PARTIE ===")

	# ═══ RÉINITIALISATION DES DONNÉES PERSISTANTES ═══
	player_score = 0      # Score remis à zéro
	player_lives = 3      # Vies standard (3 vies au démarrage)
	current_level = 1     # Commencer par le premier niveau

	print("📊 Données initialisées - Score: ", player_score, " | Vies: ", player_lives, " | Niveau: ", current_level)

	# ═══ LANCEMENT DU PREMIER NIVEAU ═══
	print("🚀 Lancement du niveau 1...")
	change_scene(SceneType.LEVEL_1)

func go_to_next_level():
	"""
	PROGRESSION VERS LE NIVEAU SUIVANT

	Cette fonction gère la progression naturelle du joueur à travers les niveaux.
	Elle incrémente le compteur de niveau et charge la scène appropriée.

	LOGIQUE DE PROGRESSION :
	- Niveau actuel + 1 → Nouveau niveau actuel
	- Si niveau ≤ 4 : Charge le niveau correspondant
	- Si niveau > 4 : Tous les niveaux terminés → Retour au menu

	UTILISATION :
	- Appelée automatiquement quand le joueur termine un niveau
	- Déclenchée via le signal level_completed des scènes de niveau
	- Gère la fin de jeu quand tous les niveaux sont terminés

	CORRESPONDANCE NIVEAU → SCÈNE :
	- Niveau 2 → SceneType.LEVEL_2
	- Niveau 3 → SceneType.LEVEL_3
	- Niveau 4 → SceneType.LEVEL_4
	- Niveau 5+ → Retour au menu (jeu terminé)

	DONNÉES PERSISTANTES :
	- Le score et les vies sont préservés entre les niveaux
	- Seul current_level est incrémenté
	"""
	# ═══ INCRÉMENTATION DU NIVEAU ═══
	current_level += 1
	print("⬆️ === PROGRESSION VERS LE NIVEAU SUIVANT ===")
	print("📈 Nouveau niveau: ", current_level)

	# ═══ SÉLECTION DE LA SCÈNE SELON LE NIVEAU ═══
	match current_level:
		2:
			print("🎯 Chargement du niveau 2...")
			change_scene(SceneType.LEVEL_2)
		3:
			print("🎯 Chargement du niveau 3...")
			change_scene(SceneType.LEVEL_3)
		4:
			print("🎯 Chargement du niveau 4 (dernier niveau)...")
			change_scene(SceneType.LEVEL_4)
		_:
			# ═══ TOUS LES NIVEAUX TERMINÉS ═══
			print("🏆 === FÉLICITATIONS ! TOUS LES NIVEAUX TERMINÉS ! ===")
			print("🎊 Le joueur a terminé tout le jeu avec succès")
			print("📊 Score final: ", player_score)
			print("🏠 Retour au menu principal...")
			change_scene(SceneType.MAIN_MENU)

func go_to_level(level_number: int):
	"""
	SAUT DIRECT VERS UN NIVEAU SPÉCIFIQUE (FONCTION DEBUG)

	Cette fonction permet de charger directement n'importe quel niveau
	sans passer par la progression normale. Très utile pour les tests.

	PARAMÈTRES :
	- level_number (int) : Numéro du niveau à charger (1-4)

	UTILISATION PRINCIPALE :
	- Tests et debug du développeur
	- Boutons de debug dans l'interface
	- Outils de développement
	- Cheat codes ou commandes de console

	DIFFÉRENCE AVEC go_to_next_level() :
	- go_to_next_level() : Progression naturelle (+1 niveau)
	- go_to_level() : Saut direct vers un niveau spécifique

	SÉCURITÉ :
	- Valide que le niveau demandé existe (1-4)
	- Affiche une erreur pour les niveaux invalides
	- Met à jour current_level pour cohérence

	ATTENTION :
	Cette fonction ne modifie PAS le score ni les vies du joueur.
	Elle change seulement le niveau actuel et charge la scène.
	"""
	print("🎯 === SAUT DIRECT VERS UN NIVEAU (DEBUG) ===")
	print("🔢 Niveau demandé: ", level_number)

	# ═══ VALIDATION DU NUMÉRO DE NIVEAU ═══
	if level_number < 1 or level_number > 4:
		print("❌ === ERREUR : NIVEAU INVALIDE ===")
		print("💥 Niveau demandé: ", level_number)
		print("✅ Niveaux valides: 1, 2, 3, 4")
		return

	# ═══ MISE À JOUR DU NIVEAU ACTUEL ═══
	current_level = level_number
	print("📝 current_level mis à jour: ", current_level)

	# ═══ CHARGEMENT DE LA SCÈNE CORRESPONDANTE ═══
	match level_number:
		1:
			print("🎮 Chargement du niveau 1...")
			change_scene(SceneType.LEVEL_1)
		2:
			print("🎮 Chargement du niveau 2...")
			change_scene(SceneType.LEVEL_2)
		3:
			print("🎮 Chargement du niveau 3...")
			change_scene(SceneType.LEVEL_3)
		4:
			print("🎮 Chargement du niveau 4...")
			change_scene(SceneType.LEVEL_4)

	print("✅ Saut vers le niveau ", level_number, " effectué")

func restart_current_level():
	"""
	REDÉMARRAGE DU NIVEAU ACTUEL

	Cette fonction recharge le niveau en cours depuis le début.
	Utilisée principalement quand le joueur meurt mais a encore des vies.

	FONCTIONNEMENT :
	- Utilise go_to_level() avec le niveau actuel
	- Recharge complètement la scène (nouvel état initial)
	- Préserve les données persistantes (score, vies)

	UTILISATION :
	- Quand le joueur meurt mais a encore des vies
	- Bouton "Recommencer le niveau" dans les menus
	- Fonctions de debug et de test

	AVANTAGES :
	- Réutilise la logique existante de go_to_level()
	- Pas de duplication de code
	- Cohérence avec les autres fonctions de navigation

	ÉTAT PRÉSERVÉ :
	- player_score : Gardé (le joueur ne perd pas ses points)
	- player_lives : Gardé (déjà décrémenté ailleurs si nécessaire)
	- current_level : Inchangé (on reste sur le même niveau)
	"""
	print("🔄 === REDÉMARRAGE DU NIVEAU ACTUEL ===")
	print("🎮 Niveau à redémarrer: ", current_level)
	print("📊 Score préservé: ", player_score)
	print("❤️ Vies restantes: ", player_lives)

	# Réutilise la logique de go_to_level() pour éviter la duplication
	go_to_level(current_level)

func return_to_menu():
	"""
	RETOUR AU MENU PRINCIPAL

	Cette fonction ramène le joueur à l'écran d'accueil principal.
	Elle est utilisée dans plusieurs contextes différents.

	CONTEXTES D'UTILISATION :
	1. Game Over : Quand le joueur n'a plus de vies
	2. Abandon volontaire : Bouton "Quitter" dans les niveaux
	3. Fin de jeu : Après avoir terminé tous les niveaux
	4. Navigation : Retour depuis les menus de paramètres

	DONNÉES PRÉSERVÉES :
	Cette fonction ne modifie PAS les données persistantes :
	- Le score reste intact
	- Les vies restent intactes
	- Le niveau actuel reste intact

	POURQUOI PRÉSERVER LES DONNÉES :
	- Permet d'afficher le score final sur le menu
	- Permet de reprendre la partie si souhaité
	- Évite les pertes de données accidentelles

	NETTOYAGE :
	Seule la scène change, pas les variables de jeu.
	Pour une vraie réinitialisation, utiliser start_game().
	"""
	print("🏠 === RETOUR AU MENU PRINCIPAL ===")
	print("📊 Données de jeu préservées - Score: ", player_score, " | Vies: ", player_lives, " | Niveau: ", current_level)
	print("🎨 Chargement de l'interface du menu...")

	change_scene(SceneType.MAIN_MENU)

# ═══════════════════════════════════════════════════════════════════════════════
# GESTIONNAIRES DE SIGNAUX (CALLBACKS)
# ═══════════════════════════════════════════════════════════════════════════════

func _on_level_completed():
	"""
	GESTIONNAIRE : NIVEAU TERMINÉ AVEC SUCCÈS

	Cette fonction est automatiquement appelée quand la scène de niveau
	émet le signal "level_completed" (quand le joueur collecte tous les dots).

	ACTIONS EFFECTUÉES :
	1. Affiche un message de félicitations
	2. Émet notre propre signal level_completed pour les autres systèmes
	3. Lance automatiquement la progression vers le niveau suivant

	FLUX D'EXÉCUTION :
	Scène de niveau → signal level_completed → cette fonction → go_to_next_level()

	DONNÉES MODIFIÉES :
	- Aucune modification directe des données persistantes
	- go_to_next_level() se charge d'incrémenter current_level

	SIGNAL RETRANSMIS :
	Le signal est re-émis par le SceneManager pour permettre à d'autres
	systèmes (UI, statistiques) d'écouter les fins de niveau.
	"""
	print("✅ === NIVEAU TERMINÉ AVEC SUCCÈS ! ===")
	print("🎉 Niveau ", current_level, " complété par le joueur")
	print("📊 Score actuel: ", player_score)

	# ═══ RETRANSMISSION DU SIGNAL ═══
	# Permet aux autres systèmes d'écouter les fins de niveau
	level_completed.emit(current_level)

	# ═══ PROGRESSION AUTOMATIQUE ═══
	print("⏭️ Lancement automatique du niveau suivant...")
	go_to_next_level()

func _on_player_died():
	"""
	GESTIONNAIRE : MORT DU JOUEUR

	Cette fonction est appelée quand le joueur meurt (collision avec fantôme).
	Elle gère la logique des vies et détermine s'il faut redémarrer ou game over.

	LOGIQUE DE VIES :
	1. Décrémenter le nombre de vies restantes
	2. Si vies > 0 : Redémarrer le niveau actuel
	3. Si vies = 0 : Déclencher le game over

	ACTIONS SELON LE CAS :
	- Vies restantes : restart_current_level() → Le joueur recommence le niveau
	- Plus de vies : _on_game_over() → Fin de partie complète

	DONNÉES MODIFIÉES :
	- player_lives : Décrémenté de 1 à chaque mort
	- Autres données préservées (score, niveau)

	SÉCURITÉ :
	La vérification <= 0 au lieu de == 0 évite les bugs
	en cas de vies négatives par erreur.
	"""
	print("💀 === MORT DU JOUEUR ===")

	# ═══ DÉCRÉMENT DES VIES ═══
	player_lives -= 1
	print("❤️ Vies perdues: 1 | Vies restantes: ", player_lives)
	print("📊 Score préservé: ", player_score)

	# ═══ LOGIQUE DE CONTINUATION OU GAME OVER ═══
	if player_lives <= 0:
		print("💥 Plus de vies disponibles - Game Over imminent")
		_on_game_over()
	else:
		print("🔄 Vies restantes - Redémarrage du niveau")
		restart_current_level()

func _on_game_over():
	"""
	GESTIONNAIRE : GAME OVER DÉFINITIF

	Cette fonction est appelée quand le joueur n'a plus de vies disponibles.
	Elle déclenche la fin de partie et le retour au menu principal.

	CONTEXTES D'APPEL :
	1. Via _on_player_died() quand player_lives <= 0
	2. Directement par les scènes de niveau en cas d'échec critique
	3. Manuellement via des commandes de debug

	ACTIONS EFFECTUÉES :
	1. Affiche les statistiques finales de la partie
	2. Émet le signal game_over pour les autres systèmes
	3. Retourne automatiquement au menu principal

	DONNÉES PRÉSERVÉES :
	Les données ne sont PAS réinitialisées ici :
	- Le score final reste visible
	- Le niveau atteint reste mémorisé
	- La réinitialisation se fait lors d'un nouveau start_game()

	SIGNAL ÉMIS :
	Le signal game_over peut être écouté par :
	- Systèmes de statistiques
	- Interfaces de score
	- Systèmes de sauvegarde
	"""
	print("💀 === GAME OVER DÉFINITIF ===")
	print("📊 === STATISTIQUES FINALES ===")
	print("🎯 Score final: ", player_score)
	print("📈 Niveau atteint: ", current_level)
	print("❤️ Vies restantes: ", player_lives, " (= 0)")

	# ═══ SIGNAL DE GAME OVER ═══
	# Permet aux autres systèmes de réagir à la fin de partie
	game_over.emit()

	# ═══ RETOUR AUTOMATIQUE AU MENU ═══
	print("🏠 Retour automatique au menu principal...")
	change_scene(SceneType.MAIN_MENU)

# ═══════════════════════════════════════════════════════════════════════════════
# FONCTIONS D'ACCÈS AUX DONNÉES PERSISTANTES
# ═══════════════════════════════════════════════════════════════════════════════

func get_player_score() -> int:
	"""
	GETTER : RÉCUPÉRATION DU SCORE ACTUEL DU JOUEUR

	Cette fonction permet aux autres scripts d'accéder au score
	sans pouvoir le modifier directement (encapsulation).

	UTILISATION TYPIQUE :
	- Affichage du score dans l'interface utilisateur
	- Calculs de bonus ou de multiplicateurs
	- Vérification de conditions basées sur le score
	- Statistiques et tableaux de scores

	RETOUR :
	- int : Score actuel du joueur (>=0)

	SÉCURITÉ :
	Cette fonction est en lecture seule. Pour modifier le score,
	utiliser add_score() qui inclut la validation et les logs.
	"""
	return player_score

func get_player_lives() -> int:
	"""
	GETTER : RÉCUPÉRATION DU NOMBRE DE VIES RESTANTES

	Cette fonction permet aux autres scripts de connaître
	le nombre de vies sans risquer de le modifier.

	UTILISATION TYPIQUE :
	- Affichage des vies dans l'interface (cœurs, compteur)
	- Logique conditionnelle basée sur les vies restantes
	- Vérifications de game over potentiel
	- Interface de debug et de test

	RETOUR :
	- int : Nombre de vies restantes (0-3 généralement)

	VALEURS POSSIBLES :
	- 3 : Début de partie ou après bonus de vie
	- 2,1 : Vies perdues mais jeu continue
	- 0 : Game over (mais les données restent)
	"""
	return player_lives

func get_current_level() -> int:
	"""
	GETTER : RÉCUPÉRATION DU NIVEAU ACTUEL

	Cette fonction permet de connaître à quel niveau
	le joueur se trouve actuellement.

	UTILISATION TYPIQUE :
	- Affichage du niveau dans l'interface
	- Génération de contenu adapté au niveau
	- Logique de difficulté progressive
	- Sauvegarde de progression

	RETOUR :
	- int : Numéro du niveau actuel (1-4)

	NOTES IMPORTANTES :
	- Le niveau reste à sa dernière valeur même après game over
	- Pour une nouvelle partie, start_game() remet à 1
	- Le niveau peut être modifié par go_to_level() (debug)
	"""
	return current_level

# ═══════════════════════════════════════════════════════════════════════════════
# FONCTIONS DE MODIFICATION DES DONNÉES PERSISTANTES
# ═══════════════════════════════════════════════════════════════════════════════

func add_score(points: int):
	"""
	AJOUT DE POINTS AU SCORE DU JOUEUR

	Cette fonction est la seule méthode recommandée pour modifier
	le score du joueur. Elle inclut validation et logging.

	PARAMÈTRES :
	- points (int) : Nombre de points à ajouter (peut être négatif)

	UTILISATION TYPIQUE :
	- Collecte de dots : add_score(10)
	- Collecte de power pellets : add_score(50)
	- Manger un fantôme : add_score(200)
	- Bonus de niveau : add_score(1000)
	- Pénalités : add_score(-100) [si implémenté]

	SÉCURITÉ :
	La fonction accepte les valeurs négatives mais affichera
	un warning si le score final devient négatif.

	VALIDATION :
	- Log automatique de chaque modification
	- Affichage des points ajoutés
	- Suivi de l'évolution du score total

	ÉVÉNEMENTS :
	Peut être étendue pour émettre des signaux en cas de
	paliers de score atteints (achievements, bonus vies, etc.)
	"""
	print("🎯 === AJOUT DE POINTS ===")
	print("➕ Points ajoutés: ", points)
	print("📊 Score avant: ", player_score)

	# ═══ MODIFICATION DU SCORE ═══
	player_score += points

	print("📊 Score après: ", player_score)

	# ═══ VALIDATION ET WARNINGS ═══
	if player_score < 0:
		print("⚠️ WARNING: Score négatif détecté (", player_score, ")")

	# ═══ AFFICHAGE DE RÉSUMÉ ═══
	if points > 0:
		print("✅ Gain de points: +", points, " → Total: ", player_score)
	elif points < 0:
		print("❌ Perte de points: ", points, " → Total: ", player_score)
	else:
		print("⚪ Aucun changement de score (points = 0)")