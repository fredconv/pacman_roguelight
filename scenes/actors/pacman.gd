extends CharacterBody2D

# === CONFIGURATION ===
@export var speed: float = GameConstants.PLAYER_SPEED

# === MOUVEMENT BASÉ SUR GRILLE STRICTE ===
const TILE_SIZE = GameConstants.CELL_SIZE
const DIRECTIONS = {
	"right": Vector2(1, 0),
	"left": Vector2(-1, 0),
	"up": Vector2(0, -1),
	"down": Vector2(0, 1),
	"none": Vector2(0, 0)
}

var current_direction: Vector2 = DIRECTIONS.right
var target_direction: Vector2 = DIRECTIONS.right

# === GAME STATS ===
var score: int = 0
var lives: int = 3

signal score_changed(new_score)
signal lives_changed(new_lives)

func _ready():
	print("🎮 Pacman initialisé avec système de mouvement basé sur grille")

	# Configurer les layers de collision
	collision_layer = 2  # Layer du joueur
	collision_mask = 1   # Collide avec les murs (layer 1)

	# ALIGNER PACMAN SUR LA GRILLE au démarrage
	var half_tile = float(TILE_SIZE) / 2.0
	global_position = global_position.snapped(Vector2(TILE_SIZE, TILE_SIZE)) + Vector2(half_tile, half_tile)
	print("📐 Position alignée sur grille: ", global_position)

	# Créer les raycasts pour détecter les murs
	create_raycasts()

	# Debug du sprite
	debug_sprite()

	# Démarrer l'animation par défaut
	start_default_animation()

	# Émettre les valeurs initiales
	score_changed.emit(score)
	lives_changed.emit(lives)

func start_default_animation():
	"""Démarre l'animation par défaut de Pacman"""
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite and sprite.has_method("play"):
		sprite.play("idle")
		print("🎬 Animation 'idle' démarrée")
	else:
		print("⚠️ Pas d'AnimatedSprite2D trouvé pour l'animation")

func debug_sprite():
	print("🔍 === DEBUG SPRITE PACMAN ===")

	# Essayer de trouver n'importe quel sprite
	var sprite = get_node_or_null("AnimatedSprite2D")
	if not sprite:
		sprite = get_node_or_null("Sprite2D")

	if sprite:
		print("✅ Noeud sprite trouvé: ", sprite.name, " (", sprite.get_class(), ")")
		print("📍 Position: ", sprite.position)
		print("📏 Scale: ", sprite.scale)
		print("🎨 Modulate: ", sprite.modulate)
		print("👁️ Visible: ", sprite.visible)
		print("🔢 Z-index: ", sprite.z_index)

		# Vérifier selon le type de sprite
		if sprite.has_method("play"):  # AnimatedSprite2D
			print("🎬 AnimatedSprite2D détecté")
			if sprite.sprite_frames:
				print("✅ SpriteFrames assigné")
				print("📦 SpriteFrames: ", sprite.sprite_frames)
				print("🎭 Animations disponibles: ", sprite.sprite_frames.get_animation_names())
			else:
				print("❌ Aucun SpriteFrames assigné!")
		else:  # Sprite2D
			print("🖼️ Sprite2D détecté")
			if sprite.texture:
				print("✅ Texture assignée")
				print("📦 Texture resource_path: ", sprite.texture.resource_path)
				print("📏 Texture size: ", sprite.texture.get_size())
			else:
				print("❌ Aucune texture assignée!")

		# FORCER la taille et position du sprite (optimisée pour le gameplay)
		print("🔧 Forçage de la taille et position du sprite...")
		sprite.scale = Vector2(2.5, 2.5)  # Taille optimale
		sprite.modulate = Color.YELLOW     # JAUNE VIF
		sprite.z_index = 5                # AU-DESSUS DES AUTRES

		# CORRECTION MANUELLE DU DÉCALAGE DU SPRITE (selon le type)
		if sprite.has_method("play"):  # AnimatedSprite2D
			sprite.position = Vector2(0, 0)     # Centré sur le Player
			sprite.offset = Vector2(0, 0)       # Pas de décalage d'offset
			sprite.centered = true              # Centré par rapport à sa position
			print("✅ AnimatedSprite2D centré à (0,0)")
		else:  # Sprite2D
			sprite.position = Vector2(GameConstants.DOUBLE_CELL, GameConstants.DOUBLE_CELL)  # 2 * CELL_SIZE
			sprite.offset = Vector2(0, 0)       # Pas de décalage d'offset
			sprite.centered = true              # Centré par rapport à sa position
			print("✅ Sprite2D positionné avec correction classique")

		# Vérification selon le type de sprite
		if sprite.has_method("play"):  # AnimatedSprite2D
			print("🎬 AnimatedSprite2D configuré - pas besoin de texture manuelle")
		else:  # Sprite2D
			# En dernier recours : créer une texture de test énorme
			if not sprite.texture or sprite.texture.get_size().x < 10:
				print("🆘 Création d'une texture de test GÉANTE...")
				var big_image = Image.create(GameConstants.DOUBLE_CELL, GameConstants.DOUBLE_CELL, false, Image.FORMAT_RGB8)
				big_image.fill(Color.RED)  # Rouge vif pour bien voir
				var big_texture = ImageTexture.new()
				big_texture.set_image(big_image)
				sprite.texture = big_texture
				print("✅ Texture rouge 64x64 créée")

	print("🔍 === FIN DEBUG SPRITE ===")

	# Debug des enfants pour voir la structure
	print("👶 Enfants du Player:")
	for child in get_children():
		print("  - ", child.name, " (", child.get_class(), ")")

var debug_timer = 0.0

func _physics_process(_delta):
	# Debug périodique du sprite (toutes les 2 secondes)
	debug_timer += _delta
	if debug_timer >= 2.0:
		debug_timer = 0.0
		var sprite = get_node_or_null("AnimatedSprite2D")
		if not sprite:
			sprite = get_node_or_null("Sprite2D")
		if sprite:
			# Vérification selon le type de sprite
			if sprite.has_method("play"):  # AnimatedSprite2D
				if not sprite.sprite_frames:
					print("⚠️ ANIMATEDSPRITE2D SANS SPRITEFRAMES - Position: ", global_position)
			else:  # Sprite2D
				if not sprite.texture:
					print("⚠️ SPRITE SANS TEXTURE DÉTECTÉ - Position: ", global_position)

			print("📏 Échelle actuelle du sprite: ", sprite.scale)
			print("🎨 Couleur actuelle: ", sprite.modulate)
			print("👁️ Visible: ", sprite.visible)

			# Re-forcer la taille et position si elle a changé (selon le type)
			var target_position = Vector2(0, 0) if sprite.has_method("play") else Vector2(GameConstants.DOUBLE_CELL, GameConstants.DOUBLE_CELL)
			if sprite.scale != Vector2(2.5, 2.5) or sprite.position != target_position:
				print("🔧 RE-FORÇAGE de la taille et position!")
				sprite.scale = Vector2(2.5, 2.5)
				sprite.position = target_position
				sprite.centered = true

	# === NOUVEAU SYSTÈME DE MOUVEMENT SIMPLE ET ROBUSTE ===

	# === MOUVEMENT BASÉ SUR GRILLE STRICTE ===

	# 1. Essayer de tourner si on est à une intersection
	attempt_turn()

	# 2. Vérifier si la direction actuelle est bloquée
	if is_direction_blocked(current_direction):
		velocity = Vector2.ZERO
		print("🛑 Arrêt - Direction bloquée")
	else:
		velocity = current_direction * speed

	# 3. Appliquer le mouvement
	move_and_slide()

	# 4. Gestion des animations
	update_animation(current_direction)

func create_raycasts():
	"""Créer les 4 raycasts pour détecter les murs dans chaque direction"""

	# RayCast vers la droite
	var ray_right = RayCast2D.new()
	ray_right.name = "RayRight"
	ray_right.target_position = Vector2(TILE_SIZE, 0)
	ray_right.collision_mask = collision_mask
	ray_right.enabled = true
	add_child(ray_right)

	# RayCast vers la gauche
	var ray_left = RayCast2D.new()
	ray_left.name = "RayLeft"
	ray_left.target_position = Vector2(-TILE_SIZE, 0)
	ray_left.collision_mask = collision_mask
	ray_left.enabled = true
	add_child(ray_left)

	# RayCast vers le haut
	var ray_up = RayCast2D.new()
	ray_up.name = "RayUp"
	ray_up.target_position = Vector2(0, -TILE_SIZE)
	ray_up.collision_mask = collision_mask
	ray_up.enabled = true
	add_child(ray_up)

	# RayCast vers le bas
	var ray_down = RayCast2D.new()
	ray_down.name = "RayDown"
	ray_down.target_position = Vector2(0, TILE_SIZE)
	ray_down.collision_mask = collision_mask
	ray_down.enabled = true
	add_child(ray_down)

	print("✅ Raycasts créés pour détection de murs")

func is_at_intersection() -> bool:
	"""Vérifie si Pacman peut tourner - système ULTRA-TOLÉRANT"""
	# On accepte de tourner dans la zone centrale de la cellule (50% de la cellule)
	var half_tile = float(TILE_SIZE) / 2.0

	var grid_x = round(global_position.x / float(TILE_SIZE))
	var grid_y = round(global_position.y / float(TILE_SIZE))
	var center_pos = Vector2(grid_x * float(TILE_SIZE) + half_tile, grid_y * float(TILE_SIZE) + half_tile)

	var distance_to_center = global_position.distance_to(center_pos)
	var tolerance = half_tile * 0.75  # 75% du demi-tile = très tolérant
	var is_centered = distance_to_center <= tolerance

	if is_centered:
		print("✅ Zone de tournant OK - Distance: ", distance_to_center, "px (max: ", tolerance, ")")
	else:
		print("❌ Hors zone de tournant - Distance: ", distance_to_center, "px (max: ", tolerance, ")")

	return is_centered

func is_direction_blocked(direction: Vector2) -> bool:
	"""Utilise les raycasts pour vérifier s'il y a un mur dans la direction"""
	var ray_cast: RayCast2D

	if direction == DIRECTIONS.right:
		ray_cast = get_node("RayRight")
	elif direction == DIRECTIONS.left:
		ray_cast = get_node("RayLeft")
	elif direction == DIRECTIONS.up:
		ray_cast = get_node("RayUp")
	elif direction == DIRECTIONS.down:
		ray_cast = get_node("RayDown")
	else:
		return false  # Direction 'none' n'est jamais bloquée

	ray_cast.force_raycast_update()
	var is_blocked = ray_cast.is_colliding()

	if is_blocked:
		print("🧱 Direction ", direction, " bloquée")
	else:
		print("✅ Direction ", direction, " libre")

	return is_blocked

func attempt_turn():
	"""VERSION SIMPLIFIÉE : Essaie de changer de direction sans restriction"""
	# Si on veut une nouvelle direction ET qu'elle est libre, on change immédiatement
	if target_direction != current_direction:
		if not is_direction_blocked(target_direction):
			current_direction = target_direction
			print("🔄 Direction changée vers: ", current_direction)
		else:
			print("❌ Direction ", target_direction, " bloquée - on continue")

func _unhandled_input(event):
	"""Gestion des entrées avec buffering"""
	if event.is_action_pressed("move_up"):
		target_direction = DIRECTIONS.up
		print("🎮 Direction cible: HAUT")
	elif event.is_action_pressed("move_down"):
		target_direction = DIRECTIONS.down
		print("🎮 Direction cible: BAS")
	elif event.is_action_pressed("move_left"):
		target_direction = DIRECTIONS.left
		print("🎮 Direction cible: GAUCHE")
	elif event.is_action_pressed("move_right"):
		target_direction = DIRECTIONS.right
		print("🎮 Direction cible: DROITE")
		return
	# Sinon, on continue dans la direction actuelle

	# 3. Appliquer le mouvement
	velocity = current_direction * speed
	move_and_slide()

	# 4. Gestion des animations
	update_animation(current_direction)

	print("🎮 Mouvement: ", current_direction, " - Position: ", global_position)

func update_animation(_input_dir: Vector2):
	"""Met à jour l'animation selon la direction du mouvement"""
	# Essayer AnimatedSprite2D d'abord, puis Sprite2D
	var sprite = get_node_or_null("AnimatedSprite2D")
	if not sprite:
		sprite = get_node_or_null("Sprite2D")

	if not sprite:
		print("❌ Aucun sprite trouvé!")
		return

	print("✅ Sprite trouvé: ", sprite.name, " (", sprite.get_class(), ")")

	# Si c'est un AnimatedSprite2D, jouer l'animation
	if sprite.has_method("play"):
		# Toujours jouer l'animation "idle" pour l'instant
		sprite.play("idle")
		print("🎬 Animation 'idle' en cours")
	else:
		print("📺 Sprite2D détecté - pas d'animation")

func add_score(points: int):
	score += points
	score_changed.emit(score)
	print("🎯 Score: ", score, " (+", points, ")")

func lose_life():
	lives -= 1
	lives_changed.emit(lives)
	print("💔 Vies restantes: ", lives)

func get_score() -> int:
	return score

func get_lives() -> int:
	return lives
