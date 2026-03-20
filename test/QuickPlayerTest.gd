extends Node

# Test rapide de chargement du Player modulaire
func _ready():
	print("🧪 === TEST CHARGEMENT PLAYER ===")

	# Essayer de charger la scène Player
	var player_scene = load("res://scenes/Player.tscn")
	if player_scene:
		print("✅ Player.tscn chargé avec succès")

		# Essayer de l'instancier
		var player_instance = player_scene.instantiate()
		if player_instance:
			print("✅ Player instancié avec succès")
			print("📋 Type: ", player_instance.get_class())
			print("📋 Script: ", player_instance.get_script())

			# Ajouter à la scène pour tester _ready
			add_child(player_instance)

			# Attendre une frame pour que _ready s'exécute
			await get_tree().process_frame

			print("✅ Player ajouté à la scène - vérifiez la console pour les messages d'initialisation")
		else:
			print("❌ Échec de l'instanciation du Player")
	else:
		print("❌ Échec du chargement de Player.tscn")

	print("🏁 === FIN DU TEST ===")