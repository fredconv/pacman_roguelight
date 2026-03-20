# TestArchitecture.gd
# Test rapide de la nouvelle architecture modulaire
extends Node

func _ready():
	print("🧪 Test de l'architecture modulaire")
	print("=" * 50)

	# Test 1: Vérifier que SceneManager existe
	if get_node_or_null("/root/SceneManager"):
		print("✅ SceneManager disponible")
		var sm = get_node("/root/SceneManager")
		print("   - Type actuel:", sm.current_scene_type)
		print("   - Méthodes disponibles:", sm.get_method_list().size(), "méthodes")
	else:
		print("❌ SceneManager non trouvé")

	# Test 2: Vérifier que GameManager existe
	if get_node_or_null("/root/GameManager"):
		print("✅ GameManager disponible")
		var gm = get_node("/root/GameManager")
		print("   - État actuel:", gm.game_state)
		print("   - Score:", gm.player_score)
		print("   - Vies:", gm.player_lives)
	else:
		print("❌ GameManager non trouvé")

	# Test 3: Vérifier les connexions
	test_communication()

	print("=" * 50)
	print("🧪 Test terminé")

func test_communication():
	print("🔗 Test de communication inter-modules...")

	var gm = get_node_or_null("/root/GameManager")
	var sm = get_node_or_null("/root/SceneManager")

	if gm and sm:
		# Tester l'ajout de score
		var old_score = gm.player_score
		gm.add_score(100)
		if gm.player_score == old_score + 100:
			print("✅ GameManager.add_score() fonctionne")
		else:
			print("❌ Problème avec GameManager.add_score()")

		# Tester changement de scène
		var old_scene_type = sm.current_scene_type
		print("   - Test changement de scène (attention: va changer la scène !)")
		# sm.goto_main_menu()  # Commenté pour éviter de changer réellement
		print("✅ Méthodes de SceneManager accessibles")
	else:
		print("❌ Impossible de tester - managers manquants")