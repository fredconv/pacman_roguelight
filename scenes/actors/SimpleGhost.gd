extends CharacterBody2D

# Fantôme simple pour les tests
class_name SimpleGhost

# Configuration
@export var speed: float = GameConstants.GHOST_SPEED

# Variables de mouvement
var move_direction: Vector2 = Vector2.UP
var possible_directions: Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

# Timer pour changer de direction
var timer: float = 0.0
var change_interval: float = 2.0  # Change de direction toutes les 2 secondes

func _ready():
	# Ajouter au groupe des fantômes
	add_to_group("ghosts")

	# Configurer les layers de collision
	collision_layer = 8  # Layer des fantômes
	collision_mask = 1   # Collide avec les murs (layer 1)

	# Choisir une direction initiale aléatoire
	move_direction = possible_directions[randi() % possible_directions.size()]

func _physics_process(delta):
	timer += delta

	# Changer de direction périodiquement ou si bloqué
	if timer >= change_interval or is_blocked():
		choose_new_direction()
		timer = 0.0

	# Mouvement
	velocity = move_direction * speed
	move_and_slide()

func is_blocked() -> bool:
	# Vérifier s'il y a un mur devant
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + move_direction * GameConstants.CELL_SIZE
	)
	query.collision_mask = 1  # Layer des murs seulement
	query.exclude = [self]

	var result = space_state.intersect_ray(query)
	return !result.is_empty()

func choose_new_direction():
	# Trouver toutes les directions libres
	var free_directions: Array[Vector2] = []

	for dir in possible_directions:
		if not is_direction_blocked(dir):
			free_directions.append(dir)

	# Si on a des directions libres, en choisir une au hasard
	if free_directions.size() > 0:
		# Préférer continuer tout droit si possible
		if move_direction in free_directions and randf() < 0.6:
			return  # Continuer dans la même direction
		else:
			move_direction = free_directions[randi() % free_directions.size()]
	else:
		# Si toutes les directions sont bloquées, faire demi-tour
		move_direction = -move_direction

func is_direction_blocked(direction: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + direction * GameConstants.CELL_SIZE
	)
	query.collision_mask = 1  # Layer des murs seulement
	query.exclude = [self]

	var result = space_state.intersect_ray(query)
	return !result.is_empty()