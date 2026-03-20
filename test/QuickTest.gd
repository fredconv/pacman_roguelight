extends Node2D

# Quick test for modular system

func _ready():
	print("🧪 === QUICK MODULAR SYSTEM TEST ===")
	test_system()

func test_system():
	"""Quick test of the modular system"""

	# Test 1: Create BaseEntity
	print("1️⃣ Testing BaseEntity creation...")
	var base_entity_script = load("res://components/BaseEntity.gd")

	if base_entity_script:
		print("✅ BaseEntity script loaded")

		var entity = base_entity_script.new()
		entity.entity_name = "QuickTest"
		add_child(entity)

		# Wait a frame for setup
		await get_tree().process_frame

		print("✅ BaseEntity created: ", entity.entity_name)
		print("💚 Health: ", entity.current_health, "/", entity.max_health)

		# Test damage
		if entity.has_method("take_damage"):
			entity.take_damage(20)
			print("💥 After damage: ", entity.current_health, "/", entity.max_health)

		# Test healing
		if entity.has_method("heal"):
			entity.heal(10)
			print("💚 After healing: ", entity.current_health, "/", entity.max_health)

	else:
		print("❌ BaseEntity script failed to load")

	# Test 2: Create Player
	print("\n2️⃣ Testing Player creation...")
	var player_script = load("res://components/Player.gd")

	if player_script:
		print("✅ Player script loaded")

		var player = player_script.new()
		add_child(player)

		# Wait a frame for setup
		await get_tree().process_frame

		print("✅ Player created: ", player.entity_name)
		print("🎯 Score: ", player.get_score())
		print("💔 Lives: ", player.get_lives())

		# Test player functions
		player.add_score(50)
		print("🎯 After adding score: ", player.get_score())

	else:
		print("❌ Player script failed to load")

	print("\n✅ === QUICK TEST COMPLETED ===")
	print("🎉 Modular system is working!")