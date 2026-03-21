extends CharacterBody2D

# Fantôme simple pour les tests
class_name SimpleGhost

# Configuration
@export var speed: float = GameConstants.GHOST_SPEED
@export var health_stats: HealthStats

# Variables de mouvement
var move_direction: Vector2 = Vector2.UP
var possible_directions: Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

# Timer pour changer de direction
var timer: float = 0.0
var change_interval: float = 2.0  # Change de direction toutes les 2 secondes

var state_machine_component: Node
var contact_death_component: Node
var health_component: HealthComponent

func _ready():
	# Ajouter au groupe des fantômes
	add_to_group("ghosts")
	setup_health_component()
	setup_combat_components()

	# Configurer les layers de collision
	collision_layer = 8  # Layer des fantômes
	collision_mask = 1   # Collide avec les murs (layer 1)

	# Choisir une direction initiale aléatoire
	move_direction = possible_directions[randi() % possible_directions.size()]

func setup_health_component() -> void:
	if has_node("HealthComponent"):
		health_component = $HealthComponent
	else:
		var health_scene = load("res://components/HealthComponent.tscn")
		health_component = health_scene.instantiate() if health_scene is PackedScene else null
		if health_component == null:
			var health_script = load("res://components/HealthComponent.gd")
			health_component = health_script.new()
		health_component.name = "HealthComponent"
		add_child(health_component)

	if health_component and health_component.has_method("setup"):
		health_component.setup(self, health_stats)
		if not health_component.entity_died.is_connected(_on_health_component_died):
			health_component.entity_died.connect(_on_health_component_died)

func _on_health_component_died(_entity: Node) -> void:
	queue_free()

func take_damage(amount: int, source: Node = null) -> void:
	if health_component and health_component.has_method("take_damage"):
		health_component.take_damage(amount, source)

func heal(amount: int) -> void:
	if health_component and health_component.has_method("heal"):
		health_component.heal(amount)

func is_alive() -> bool:
	if health_component and health_component.has_method("is_alive"):
		return health_component.is_alive()
	return true

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