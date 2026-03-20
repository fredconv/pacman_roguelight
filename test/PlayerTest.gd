extends Node2D

# Test simple pour vérifier le Player modulaire
func _ready():
	print("🧪 === TEST PLAYER MODULAIRE ===")

	# Créer une instance du Player modulaire
	var player_scene = preload("res://scenes/actors/Player.tscn")
	var player = player_scene.instantiate()

	# Position le player au centre
	player.position = Vector2(400, 300)
	add_child(player)

	print("✅ Player modulaire créé et ajouté à la scène")
	print("🎮 Composants du Player:")

	# Vérifier que tous les composants sont présents
	await get_tree().process_frame  # Attendre une frame pour _ready

	if player.health_component:
		print("  ✅ HealthComponent - HP: ", player.current_health, "/", player.max_health)
	else:
		print("  ❌ HealthComponent manquant")

	if player.movement_component:
		print("  ✅ MovementComponent - Speed: ", player.current_speed)
	else:
		print("  ❌ MovementComponent manquant")

	if player.ability_component:
		print("  ✅ AbilityComponent - Mana: ", player.current_mana, "/", player.max_mana)
	else:
		print("  ❌ AbilityComponent manquant")

	# Tester quelques propriétés
	print("🎯 Score: ", player.score)
	print("❤️ Lives: ", player.lives)
	print("⚡ Entity Name: ", player.entity_name)

	print("🎉 === TEST PLAYER TERMINÉ ===")
	print("ℹ️ Utilisez les flèches pour bouger, Espace pour Blink")