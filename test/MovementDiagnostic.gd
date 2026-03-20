extends Node2D

# Test de debug avancé pour le mouvement du Player
func _ready():
	print("🔍 === DIAGNOSTIC MOUVEMENT PLAYER ===")

	# Attendre que tout soit chargé
	await get_tree().process_frame

	# Trouver le player dans la scène
	var player = find_player_in_scene()

	if not player:
		print("❌ ERREUR: Aucun Player trouvé dans la scène!")
		return

	print("✅ Player trouvé: ", player.name)
	print("📍 Position: ", player.global_position)
	print("📊 Type: ", player.get_class())
	print("📜 Script: ", player.get_script())

	# Vérifier les composants
	check_player_components(player)

	# Vérifier les RayCast2D
	check_raycasts(player)

	# Vérifier les collision layers
	check_collision_setup(player)

	# Test de mouvement manuel
	test_manual_movement(player)

func find_player_in_scene() -> Node:
	"""Trouve le Player dans la scène courante"""
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]

	# Chercher par nom
	var group_player = get_tree().get_first_node_in_group("player")
	if group_player:
		return group_player
	return find_node_by_name(get_tree().current_scene, "Player")

func find_node_by_name(node: Node, target_name: String) -> Node:
	"""Recherche récursive par nom"""
	if node.name == target_name:
		return node
	for child in node.get_children():
		var result = find_node_by_name(child, target_name)
		if result:
			return result
	return null

func check_player_components(player: Node):
	"""Vérifier les composants du Player"""
	print("\n🧩 === COMPOSANTS PLAYER ===")

	if player.has_method("get_health_component"):
		print("✅ HealthComponent disponible")
	else:
		print("❌ HealthComponent manquant")

	if player.has_method("get_movement_component"):
		print("✅ MovementComponent disponible")
	else:
		print("❌ MovementComponent manquant")

	if player.has_method("get_ability_component"):
		print("✅ AbilityComponent disponible")
	else:
		print("❌ AbilityComponent manquant")

func check_raycasts(player: Node):
	"""Vérifier les RayCast2D"""
	print("\n🔍 === RAYCASTS ===")

	var raycast_names = ["RayCast2D_Right", "RayCast2D_Left", "RayCast2D_Up", "RayCast2D_Down"]

	for ray_name in raycast_names:
		var ray = player.get_node_or_null(ray_name)
		if ray:
			print("✅ ", ray_name, " - Enabled: ", ray.enabled, " - Mask: ", ray.collision_mask)
			ray.force_raycast_update()
			print("   └─ Colliding: ", ray.is_colliding())
			if ray.is_colliding():
				print("   └─ Collision avec: ", ray.get_collider())
		else:
			print("❌ ", ray_name, " manquant")

func check_collision_setup(player: Node):
	"""Vérifier la configuration des collisions"""
	print("\n⚙️ === COLLISION SETUP ===")

	if player is CharacterBody2D:
		print("✅ Player est CharacterBody2D")
		print("📊 collision_layer: ", player.collision_layer)
		print("📊 collision_mask: ", player.collision_mask)
	else:
		print("❌ Player n'est pas CharacterBody2D: ", player.get_class())

func test_manual_movement(player: Node):
	"""Test de mouvement manuel"""
	print("\n🎮 === TEST MOUVEMENT MANUEL ===")

	if player.has_method("_physics_process"):
		print("✅ _physics_process disponible")
	else:
		print("❌ _physics_process manquant")

	if player.has_method("_unhandled_input"):
		print("✅ _unhandled_input disponible")
	else:
		print("❌ _unhandled_input manquant")

	# Vérifier les propriétés de mouvement
	if player.has_property("current_speed"):
		print("📏 current_speed: ", player.current_speed)
	if player.has_property("current_direction"):
		print("🧭 current_direction: ", player.current_direction)
	if player.has_property("velocity"):
		print("⚡ velocity: ", player.velocity)

func has_property(node: Node, property_name: String) -> bool:
	"""Vérifier si un node a une propriété"""
	return property_name in node