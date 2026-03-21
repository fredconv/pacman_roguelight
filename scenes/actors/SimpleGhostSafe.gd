extends CharacterBody2D

# Fantôme simple sans dépendances externes
class_name SimpleGhostSafe

# Configuration basique
@export var speed: float = 100.0

# Grid system (comme le player)
const TILE_SIZE = 32  # GameConstants.CELL_SIZE
const SNAP_THRESHOLD: float = 3.0
const SNAP_SPEED: float = 1.0

# Variables de mouvement
var move_direction: Vector2 = Vector2.RIGHT
var target_direction: Vector2 = Vector2.RIGHT
var possible_directions: Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
var is_snapping_to_grid: bool = false

# Raycasts pour détection des murs
var ray_center: RayCast2D
var raycast_length: float = 20.0

# Timer pour changer de direction
var timer: float = 0.0
var change_interval: float = 2.0

var state_machine_component: Node
var contact_death_component: Node

func _ready():
	print("👻 SimpleGhost initialisé")

	# Ajouter au groupe des fantômes
	add_to_group("ghosts")
	setup_combat_components()

	# Configurer les layers de collision
	collision_layer = 8  # Layer des fantômes
	collision_mask = 1   # Collide avec les murs

	# Aligner sur la grille dès le départ
	var half_tile = float(TILE_SIZE) / 2.0
	global_position = global_position.snapped(Vector2(TILE_SIZE, TILE_SIZE)) + Vector2(half_tile, half_tile)

	# Créer le raycast pour la détection
	create_raycast()

	# Choisir une direction initiale aléatoire
	move_direction = possible_directions[randi() % possible_directions.size()]
	target_direction = move_direction
	print("👻 Direction initiale: ", move_direction)

func setup_combat_components() -> void:
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
		state_machine_component.set_state(&"chase")

	if contact_death_component and contact_death_component.has_method("setup"):
		contact_death_component.setup(self, state_machine_component, contact_death_component.Team.GHOST)
		contact_death_component.contact_radius = 8.0
		contact_death_component.defeated.connect(_on_defeated_by_contact)

func get_contact_death_component() -> Node:
	return contact_death_component

func _on_defeated_by_contact(_victim: Node, _killer: Node) -> void:
	queue_free()

func create_raycast():
	"""Créer un raycast pour détecter les murs"""
	ray_center = RayCast2D.new()
	ray_center.name = "RayCast_Center"
	ray_center.enabled = true
	ray_center.collision_mask = 1  # Détecte les murs
	ray_center.collide_with_areas = false
	ray_center.collide_with_bodies = true
	add_child(ray_center)
	update_raycast_direction(move_direction)

func update_raycast_direction(direction: Vector2):
	"""Mettre à jour la direction du raycast"""
	if ray_center:
		ray_center.target_position = direction * raycast_length

func _physics_process(delta):
	timer += delta

	# Changer de direction périodiquement ou à chaque intersection
	if timer >= change_interval or is_at_intersection():
		timer = 0.0
		choose_new_direction()

	# Appliquer le mouvement
	if not is_direction_blocked(move_direction):
		velocity = move_direction * speed
	else:
		velocity = Vector2.ZERO
		# Direction bloquée, changer immédiatement
		choose_new_direction()

	move_and_slide()

	# Aligner sur la grille dans l'axe perpendiculaire
	align_perpendicular_axis()

	# Auto-snap si très proche du centre
	auto_snap_to_center()

func is_direction_blocked(direction: Vector2) -> bool:
	"""Vérifier si une direction est bloquée"""
	if direction == Vector2.ZERO:
		return false

	update_raycast_direction(direction)
	ray_center.force_raycast_update()

	return ray_center.is_colliding()

func is_at_intersection() -> bool:
	"""Vérifier si le fantôme est à une intersection (plusieurs directions possibles)"""
	if not is_aligned_on_grid():
		return false

	# Compter combien de directions sont libres
	var free_directions = 0
	for dir in possible_directions:
		if not is_direction_blocked(dir):
			free_directions += 1

	# C'est une intersection s'il y a plus de 2 directions libres
	# (2 = couloir droit, >2 = intersection/tournant)
	return free_directions > 2

func choose_new_direction():
	"""Choisir une nouvelle direction intelligemment"""
	# Lister toutes les directions libres
	var free_directions: Array[Vector2] = []
	for dir in possible_directions:
		if not is_direction_blocked(dir):
			free_directions.append(dir)

	if free_directions.size() == 0:
		# Aucune direction libre, essayer de revenir en arrière
		move_direction = -move_direction
		return

	# Éviter de revenir en arrière si possible
	var alternatives = free_directions.filter(func(dir): return dir != -move_direction)
	if alternatives.size() > 0:
		move_direction = alternatives[randi() % alternatives.size()]
	else:
		# Sinon prendre n'importe quelle direction libre
		move_direction = free_directions[randi() % free_directions.size()]

	update_raycast_direction(move_direction)

# === GRID ALIGNMENT FUNCTIONS ===
func get_distance_to_cell_center() -> Vector2:
	"""Calcule la distance par rapport au centre de la cellule actuelle avec fmod"""
	var half_tile = float(TILE_SIZE) / 2.0

	# Utiliser fmod pour obtenir la position relative dans la cellule
	var offset_x = fmod(global_position.x - half_tile, TILE_SIZE)
	var offset_y = fmod(global_position.y - half_tile, TILE_SIZE)

	return Vector2(offset_x, offset_y)

func is_aligned_on_grid() -> bool:
	"""Vérifie si le fantôme est bien aligné sur le centre d'une cellule"""
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

func align_perpendicular_axis():
	"""Aligner sur la grille dans l'axe perpendiculaire au mouvement"""
	var cell_center = get_nearest_grid_center()

	# Si on se déplace horizontalement, aligner verticalement
	if abs(move_direction.x) > 0.1:
		global_position.y = lerp(global_position.y, cell_center.y, SNAP_SPEED)

	# Si on se déplace verticalement, aligner horizontalement
	if abs(move_direction.y) > 0.1:
		global_position.x = lerp(global_position.x, cell_center.x, SNAP_SPEED)

func auto_snap_to_center():
	"""Snap automatiquement au centre si très proche"""
	var grid_center = get_nearest_grid_center()
	var distance = global_position.distance_to(grid_center)

	# Si très proche du centre (< 0.5px), snap direct
	if distance < 0.5:
		global_position = grid_center