extends BaseEntity
class_name Player

# === PLAYER SPECIFIC PROPERTIES ===
@export var score: int = 0
@export var lives: int = 1
@export var base_lives: int = 1

# === PLAYER STATUS ===
enum PlayerStatus {
	NORMAL,      # Statut par défaut - fantômes dangereux
	HUNTER       # Après power pellet - peut manger les fantômes
}

var current_status: PlayerStatus = PlayerStatus.NORMAL
var hunter_timer: Timer
var hunter_duration: float = 10.0  # Durée en secondes du mode hunter

signal status_changed(new_status: PlayerStatus)
signal hunter_mode_started
signal hunter_mode_ended

# === MOVEMENT GRID SYSTEM ===
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
var is_snapping_to_grid: bool = false  # En train de s'aligner sur le centre
const SNAP_THRESHOLD: float = 3.0  # Distance max pour considérer qu'on doit snapper
const SNAP_SPEED: float = 1.0  # Vitesse d'interpolation (1.0 = snap immédiat)

# === RAYCASTS FOR COLLISION ===
# 3 raycasts dynamiques : centre, haut et bas dans la direction du mouvement
var ray_center: RayCast2D
var ray_top: RayCast2D
var ray_bottom: RayCast2D
var raycast_length: float = 20.0  # Longueur des raycasts (réduite pour éviter faux positifs)
var raycast_offset: float = 8.0  # Offset perpendiculaire (réduit pour rester dans le couloir)

# === GAME PROPERTIES ===
var spawn_position: Vector2

# === SIGNALS ===
signal score_changed(new_score: int)
signal lives_changed(new_lives: int)
signal player_caught
signal life_lost(remaining_lives: int)

var state_machine_component: Node
var contact_death_component: Node
var _death_emitted: bool = false
var extra_lives_bonus: int = 0
var speed_bonus_multiplier: float = 0.0
var base_move_speed: float = GameConstants.PLAYER_SPEED

func _ready():
	# Setup BaseEntity first
	entity_name = "Player"
	max_health = 100
	current_health = 100
	max_mana = 50
	current_mana = 50
	max_speed = GameConstants.PLAYER_SPEED
	current_speed = GameConstants.PLAYER_SPEED
	base_move_speed = GameConstants.PLAYER_SPEED

	# Call parent _ready
	super._ready()

	print("🎮 Player initialized with modular system")

	# Setup player-specific stuff
	setup_player_specifics()
	setup_combat_components()

	# Emit initial values
	score_changed.emit(score)
	lives_changed.emit(lives)

func setup_player_specifics():
	"""Setup player-specific configuration"""

	# Add to player group for easy reference
	add_to_group("player")
	print("👥 Player added to 'player' group")

	# Configure collision layers (keep scene values, just document them)
	print("⚙️ Collision setup - Layer: ", collision_layer, " Mask: ", collision_mask)

	# Align on grid
	var half_tile = float(TILE_SIZE) / 2.0
	global_position = global_position.snapped(Vector2(TILE_SIZE, TILE_SIZE)) + Vector2(half_tile, half_tile)
	print("📐 Player position aligned on grid: ", global_position)

	# Create raycasts for wall detection
	create_raycasts()

	# Create hunter mode timer
	create_hunter_timer()

	# Setup sprite
	debug_sprite()
	start_default_animation()

func setup_combat_components():
	"""Setup reusable state/death components for contact combat."""
	if not has_node("StateMachineComponent"):
		var state_machine_script = load("res://components/StateMachineComponent.gd")
		state_machine_component = state_machine_script.new()
		state_machine_component.name = "StateMachineComponent"
		add_child(state_machine_component)
	else:
		state_machine_component = $StateMachineComponent

	if not has_node("ContactDeathComponent"):
		var contact_death_script = load("res://components/ContactDeathComponent.gd")
		contact_death_component = contact_death_script.new()
		contact_death_component.name = "ContactDeathComponent"
		add_child(contact_death_component)
	else:
		contact_death_component = $ContactDeathComponent

	if state_machine_component and state_machine_component.has_method("set_state"):
		state_machine_component.set_state(&"normal")

	if contact_death_component and contact_death_component.has_method("setup"):
		contact_death_component.setup(self, state_machine_component, contact_death_component.Team.PLAYER)
		contact_death_component.contact_radius = 8.0
		contact_death_component.defeated.connect(_on_defeated_by_contact)

func create_hunter_timer():
	"""Créer le timer pour le mode hunter"""
	hunter_timer = Timer.new()
	hunter_timer.name = "HunterTimer"
	hunter_timer.one_shot = true
	hunter_timer.timeout.connect(_on_hunter_timer_timeout)
	add_child(hunter_timer)
	print("⏱️ Hunter timer créé")

func create_raycasts():
	"""Créer 3 raycasts dynamiques (centre, haut, bas) qui s'orientent dans la direction du mouvement"""

	# Créer le raycast central
	ray_center = RayCast2D.new()
	ray_center.name = "RayCast_Center"
	ray_center.enabled = true
	ray_center.collision_mask = 1  # Détecte les murs (layer 1)
	ray_center.collide_with_areas = false
	ray_center.collide_with_bodies = true
	add_child(ray_center)

	# Créer le raycast supérieur (offset perpendiculaire)
	ray_top = RayCast2D.new()
	ray_top.name = "RayCast_Top"
	ray_top.enabled = true
	ray_top.collision_mask = 1
	ray_top.collide_with_areas = false
	ray_top.collide_with_bodies = true
	add_child(ray_top)

	# Créer le raycast inférieur (offset perpendiculaire)
	ray_bottom = RayCast2D.new()
	ray_bottom.name = "RayCast_Bottom"
	ray_bottom.enabled = true
	ray_bottom.collision_mask = 1
	ray_bottom.collide_with_areas = false
	ray_bottom.collide_with_bodies = true
	add_child(ray_bottom)

	print("✅ 3 raycasts dynamiques créés (centre, haut, bas)")
	print("📏 Longueur des raycasts: ", raycast_length)
	print("📏 Offset perpendiculaire: ", raycast_offset)

	# Initialiser les raycasts dans la direction de départ
	update_raycast_directions(current_direction)

# === GRID ALIGNMENT FUNCTIONS ===
func get_distance_to_cell_center() -> Vector2:
	"""Calcule la distance par rapport au centre de la cellule actuelle avec fmod"""
	var half_tile = float(TILE_SIZE) / 2.0

	# Utiliser fmod pour obtenir la position relative dans la cellule
	var offset_x = fmod(global_position.x - half_tile, TILE_SIZE)
	var offset_y = fmod(global_position.y - half_tile, TILE_SIZE)

	return Vector2(offset_x, offset_y)

func is_aligned_on_grid() -> bool:
	"""Vérifie si le player est bien aligné sur le centre d'une cellule"""
	var distance = get_distance_to_cell_center()
	var total_distance = distance.length()

	return total_distance < SNAP_THRESHOLD

func get_nearest_grid_center() -> Vector2:
	"""Retourne la position du centre de cellule le plus proche"""
	var half_tile = float(TILE_SIZE) / 2.0

	# Arrondir à la grille et ajouter le demi-tile pour centrer
	var snapped_x = round((global_position.x - half_tile) / TILE_SIZE) * TILE_SIZE + half_tile
	var snapped_y = round((global_position.y - half_tile) / TILE_SIZE) * TILE_SIZE + half_tile

	return Vector2(snapped_x, snapped_y)

func snap_to_grid_center(_delta: float):
	"""Snap instantanément au centre de la cellule - pas de lerp progressif"""
	var target_pos = get_nearest_grid_center()

	# Snap direct sans interpolation pour garantir une position EXACTE
	global_position = target_pos
	is_snapping_to_grid = false

func needs_to_change_axis(from_dir: Vector2, to_dir: Vector2) -> bool:
	"""Vérifie si le changement de direction nécessite un changement d'axe"""
	# Changement d'axe = passer de horizontal à vertical ou vice-versa
	var from_horizontal = abs(from_dir.x) > 0
	var to_horizontal = abs(to_dir.x) > 0

	return from_horizontal != to_horizontal

# === INPUT HANDLING ===
func _unhandled_input(event):
	"""Handle player input"""
	# Movement input
	if event.is_action_pressed("move_up"):
		target_direction = DIRECTIONS.up
	elif event.is_action_pressed("move_down"):
		target_direction = DIRECTIONS.down
	elif event.is_action_pressed("move_left"):
		target_direction = DIRECTIONS.left
	elif event.is_action_pressed("move_right"):
		target_direction = DIRECTIONS.right

	if event.is_action_pressed("dash") and ability_component and ability_component.has_method("activate_input_action"):
		ability_component.activate_input_action(&"dash")

# === MOVEMENT SYSTEM ===
func _physics_process(delta: float):
	# Call parent physics process for regeneration
	super._physics_process(delta)

	# Si on est en train de s'aligner sur la grille, snap immédiatement
	if is_snapping_to_grid:
		snap_to_grid_center(delta)
		# Une fois aligné, on retente le changement de direction
		attempt_turn()
		return

	# Handle movement
	attempt_turn()

	# Check if current direction is blocked
	if is_direction_blocked(current_direction):
		velocity = Vector2.ZERO
	else:
		velocity = current_direction * current_speed

	# Apply movement
	move_and_slide()

	# APRÈS le mouvement: aligner sur la grille dans l'axe perpendiculaire
	# Si on se déplace horizontalement, on aligne verticalement (et vice-versa)
	var cell_center = get_nearest_grid_center()

	if abs(current_direction.x) > 0:  # Mouvement horizontal
		# Forcer la position Y au centre exact de la cellule
		global_position.y = cell_center.y
	elif abs(current_direction.y) > 0:  # Mouvement vertical
		# Forcer la position X au centre exact de la cellule
		global_position.x = cell_center.x

	# Debug collision info
	if get_slide_collision_count() > 0:
		print("💥 Collision detected during move_and_slide()")

	# Update animations
	update_animation(current_direction)

func attempt_turn():
	"""Essaye de changer de direction - nécessite d'être au centre si changement d'axe"""
	if target_direction == current_direction:
		return

	# Vérifier si la nouvelle direction est bloquée
	if is_direction_blocked(target_direction):
		return

	# Si c'est un changement d'axe (horizontal -> vertical ou vice-versa)
	if needs_to_change_axis(current_direction, target_direction):
		# On doit être aligné sur le centre pour tourner
		if not is_aligned_on_grid():
			is_snapping_to_grid = true
			return

	# Changer de direction
	current_direction = target_direction
	# Mettre à jour les raycasts pour la nouvelle direction
	update_raycast_directions(current_direction)
	is_snapping_to_grid = false

func update_raycast_directions(direction: Vector2):
	"""Met à jour les 3 raycasts pour pointer dans la direction donnée"""
	if direction == Vector2.ZERO:
		return

	# Direction principale (normalisée)
	var main_dir = direction.normalized()

	# Direction perpendiculaire (pour les offsets haut/bas)
	var perp_dir = Vector2(-main_dir.y, main_dir.x)

	# Raycast central : pointe dans la direction principale
	ray_center.target_position = main_dir * raycast_length

	# Raycast haut : offset perpendiculaire positif
	ray_top.position = perp_dir * raycast_offset
	ray_top.target_position = main_dir * raycast_length

	# Raycast bas : offset perpendiculaire négatif
	ray_bottom.position = -perp_dir * raycast_offset
	ray_bottom.target_position = main_dir * raycast_length

func is_direction_blocked(direction: Vector2) -> bool:
	"""Vérifie si la direction est bloquée en utilisant les 3 raycasts"""
	if direction == Vector2.ZERO:
		return false

	# Mettre à jour les raycasts pour la direction testée
	update_raycast_directions(direction)

	# Forcer la mise à jour des raycasts
	ray_center.force_raycast_update()
	ray_top.force_raycast_update()
	ray_bottom.force_raycast_update()

	# Vérifier si au moins un raycast détecte une collision
	var center_blocked = ray_center.is_colliding()
	var top_blocked = ray_top.is_colliding()
	var bottom_blocked = ray_bottom.is_colliding()

	var is_blocked = center_blocked or top_blocked or bottom_blocked

	return is_blocked

# === PLAYER SPECIFIC FUNCTIONS ===
func add_score(points: int):
	"""Add points to score using BaseEntity system"""
	score += points
	score_changed.emit(score)
	print("🎯 Score: ", score, " (+", points, ")")

func activate_hunter_mode():
	"""Activer le mode hunter après avoir mangé un power pellet"""
	if current_status == PlayerStatus.HUNTER:
		# Si déjà en mode hunter, réinitialiser le timer
		hunter_timer.start(hunter_duration)
		print("🔄 Mode hunter prolongé - timer réinitialisé")
	else:
		# Activer le mode hunter
		current_status = PlayerStatus.HUNTER
		hunter_timer.start(hunter_duration)
		print("⚡ Mode HUNTER activé pour ", hunter_duration, " secondes!")

		# Changer l'apparence du player (modulation de couleur)
		var sprite = get_node_or_null("AnimatedSprite2D")
		if not sprite:
			sprite = get_node_or_null("Sprite2D")
		if sprite:
			sprite.modulate = Color(1.0, 0.8, 0.0)  # Jaune doré

		status_changed.emit(current_status)
		hunter_mode_started.emit()
		if state_machine_component and state_machine_component.has_method("set_state"):
			state_machine_component.set_state(&"powered")

func deactivate_hunter_mode():
	"""Désactiver le mode hunter"""
	if current_status == PlayerStatus.HUNTER:
		current_status = PlayerStatus.NORMAL
		print("⏹️ Mode hunter terminé - retour au mode normal")

		# Restaurer l'apparence normale
		var sprite = get_node_or_null("AnimatedSprite2D")
		if not sprite:
			sprite = get_node_or_null("Sprite2D")
		if sprite:
			sprite.modulate = Color(1.0, 1.0, 1.0)

		status_changed.emit(current_status)
		hunter_mode_ended.emit()
		if state_machine_component and state_machine_component.has_method("set_state"):
			state_machine_component.set_state(&"normal")

func _on_hunter_timer_timeout():
	"""Callback quand le timer du mode hunter expire"""
	deactivate_hunter_mode()

func is_hunter() -> bool:
	"""Vérifier si le joueur est en mode hunter"""
	return current_status == PlayerStatus.HUNTER

func can_eat_ghosts() -> bool:
	"""Vérifier si le joueur peut manger les fantômes"""
	return is_hunter()

func get_remaining_hunter_time() -> float:
	"""Obtenir le temps restant du mode hunter"""
	if hunter_timer and not hunter_timer.is_stopped():
		return hunter_timer.time_left
	return 0.0

func lose_life():
	"""Lose a life - could trigger death if no lives left"""
	lives = maxi(0, lives - 1)
	lives_changed.emit(lives)
	print("💔 Lives remaining: ", lives)
	life_lost.emit(lives)

func get_score() -> int:
	return score

func get_lives() -> int:
	return lives

func get_max_lives() -> int:
	return base_lives + extra_lives_bonus

func reset_lives_to_max() -> void:
	lives = get_max_lives()
	lives_changed.emit(lives)

func add_extra_lives(amount: int) -> void:
	extra_lives_bonus = maxi(0, extra_lives_bonus + amount)
	reset_lives_to_max()

func set_speed_bonus_multiplier(multiplier: float) -> void:
	speed_bonus_multiplier = maxf(0.0, multiplier)
	current_speed = base_move_speed * (1.0 + speed_bonus_multiplier)
	max_speed = current_speed

func get_ability_component() -> Node:
	return ability_component

func dash_forward(cell_count: int) -> bool:
	var dash_direction := current_direction if current_direction != Vector2.ZERO else target_direction
	if dash_direction == Vector2.ZERO:
		return false
	var start_position := global_position
	global_position = get_nearest_grid_center()
	var destination := global_position
	for _step in range(cell_count):
		if is_direction_blocked(dash_direction):
			break
		destination += dash_direction * TILE_SIZE
		global_position = destination
	velocity = Vector2.ZERO
	update_raycast_directions(dash_direction)
	update_animation(dash_direction)
	return destination.distance_to(start_position) > 0.0

# === SPRITE SYSTEM (copied from original) ===
var debug_timer = 0.0

func debug_sprite():
	print("🔍 === DEBUG SPRITE PLAYER ===")

	var sprite = get_node_or_null("AnimatedSprite2D")
	if not sprite:
		sprite = get_node_or_null("Sprite2D")

	if sprite:
		print("✅ Sprite node found: ", sprite.name, " (", sprite.get_class(), ")")
		print("📍 Position: ", sprite.position)
		print("📏 Scale: ", sprite.scale)
		print("🎨 Modulate: ", sprite.modulate)
		print("👁️ Visible: ", sprite.visible)
		print("🔢 Z-index: ", sprite.z_index)

		# Configure sprite
		sprite.scale = Vector2(2.5, 2.5)
		sprite.modulate = Color.YELLOW
		sprite.z_index = 5

		if sprite.has_method("play"):
			sprite.position = Vector2(0, 0)
			sprite.offset = Vector2(0, 0)
			sprite.centered = true
			print("✅ AnimatedSprite2D configured")
		else:
			sprite.position = Vector2(GameConstants.DOUBLE_CELL, GameConstants.DOUBLE_CELL)
			sprite.offset = Vector2(0, 0)
			sprite.centered = true
			print("✅ Sprite2D configured")

	print("🔍 === END DEBUG SPRITE ===")

func start_default_animation():
	"""Start default animation"""
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite and sprite.has_method("play"):
		var sprite_frames = sprite.sprite_frames
		if sprite_frames and sprite_frames.has_animation("default"):
			sprite.play("default")
			print("🎬 Animation 'default' started")
		elif sprite_frames and sprite_frames.has_animation("idle"):
			sprite.play("idle")
			print("🎬 Animation 'idle' started")
		else:
			print("⚠️ No compatible startup animation found on AnimatedSprite2D")
	else:
		print("⚠️ No AnimatedSprite2D found for animation")

func update_animation(direction: Vector2):
	"""Update animation and sprite orientation based on movement direction"""
	var sprite = get_node_or_null("AnimatedSprite2D")
	if not sprite:
		sprite = get_node_or_null("Sprite2D")

	if not sprite:
		return

	# Réinitialiser la rotation et le flip
	sprite.rotation = 0
	sprite.flip_h = false

	# Orienter le sprite selon la direction
	if direction == DIRECTIONS.left:
		# Gauche : flip horizontal
		sprite.flip_h = true
	elif direction == DIRECTIONS.up:
		# Haut : rotation -90° (anti-horaire)
		sprite.rotation = -PI / 2
	elif direction == DIRECTIONS.down:
		# Bas : rotation +90° (horaire)
		sprite.rotation = PI / 2
	# Droite : pas de modification (orientation par défaut)

	if sprite.has_method("play"):
		sprite.play("default")

# === OVERRIDE BASEENTITY SIGNALS ===
func _on_entity_died(_entity):
	"""Handle player death"""
	defeat()

func _on_defeated_by_contact(_victim: Node, _killer: Node):
	lose_life()
	if lives <= 0:
		defeat()
	else:
		var respawn_position := spawn_position if spawn_position != Vector2.ZERO else global_position
		revive_at(respawn_position)

func get_contact_death_component() -> Node:
	return contact_death_component

func is_defeated() -> bool:
	return state_machine_component and state_machine_component.has_method("is_state") and state_machine_component.is_state(&"dead")

func defeat() -> void:
	if is_defeated():
		return
	if state_machine_component and state_machine_component.has_method("set_state"):
		state_machine_component.set_state(&"dead")
	visible = false
	set_physics_process(false)
	set_process_unhandled_input(false)
	collision_layer = 0
	collision_mask = 0
	if not _death_emitted:
		_death_emitted = true
		player_caught.emit()

func revive_at(spawn_pos: Vector2) -> void:
	_death_emitted = false
	visible = true
	set_physics_process(true)
	set_process_unhandled_input(true)
	collision_layer = 2
	collision_mask = 14
	global_position = spawn_pos
	velocity = Vector2.ZERO
	current_direction = DIRECTIONS.right
	target_direction = DIRECTIONS.right
	spawn_position = spawn_pos
	deactivate_hunter_mode()
	if state_machine_component and state_machine_component.has_method("set_state"):
		state_machine_component.set_state(&"normal")

func reset_for_level():
	"""Reset player for new level"""
	print("🔄 Player reset for level")
	# Reset health and mana
	current_health = max_health
	current_mana = max_mana

	# Reset position to spawn
	if spawn_position != Vector2.ZERO:
		revive_at(spawn_position)

	# Reset movement
	current_direction = DIRECTIONS.right
	target_direction = DIRECTIONS.right
	velocity = Vector2.ZERO

	# Reset any status effects via health component
	if health_component:
		health_component.heal(max_health)  # Full heal

	print("✅ Player reset complete")