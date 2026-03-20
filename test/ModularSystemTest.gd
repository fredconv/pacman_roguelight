extends Node

# Complete test scene for the modular system

func _ready():
	print("🧪 === MODULAR SYSTEM COMPLETE TEST ===")

	# Test order: Components -> BaseEntity -> Player
	await test_individual_components()
	await test_base_entity()
	await test_player_creation()

	print("✅ === ALL TESTS COMPLETED ===")

func test_individual_components():
	"""Test each component individually"""
	print("\n🔧 === TESTING INDIVIDUAL COMPONENTS ===")

	# Test HealthComponent
	print("💚 Testing HealthComponent...")
	var health_script = load("res://components/HealthComponent.gd")
	if health_script:
		var health_comp = health_script.new()
		add_child(health_comp)
		print("✅ HealthComponent created successfully")
	else:
		print("❌ HealthComponent failed to load")

	# Test MovementComponent
	print("🏃 Testing MovementComponent...")
	var movement_script = load("res://components/MovementComponent.gd")
	if movement_script:
		var movement_comp = movement_script.new()
		add_child(movement_comp)
		print("✅ MovementComponent created successfully")
	else:
		print("❌ MovementComponent failed to load")

	# Test AbilityComponent
	print("⚡ Testing AbilityComponent...")
	var ability_script = load("res://components/AbilityComponent.gd")
	if ability_script:
		var ability_comp = ability_script.new()
		add_child(ability_comp)
		print("✅ AbilityComponent created successfully")
	else:
		print("❌ AbilityComponent failed to load")

	# Test Blink ability
	print("✨ Testing Blink Ability...")
	var blink_script = load("res://scenes/abilities/blink.gd")
	if blink_script:
		var blink_ability = blink_script.new()
		print("✅ Blink ability created successfully")
		print("📝 Description: ", blink_ability.get_description())
		print("🔮 Mana cost: ", blink_ability.get_mana_cost())
		print("⏰ Cooldown: ", blink_ability.get_cooldown())
	else:
		print("❌ Blink ability failed to load")

func test_base_entity():
	"""Test BaseEntity creation and functionality"""
	print("\n🏗️ === TESTING BASE ENTITY ===")

	var base_entity_script = load("res://components/BaseEntity.gd")
	if not base_entity_script:
		print("❌ BaseEntity script failed to load")
		return

	var entity = base_entity_script.new()
	entity.entity_name = "TestEntity"
	entity.max_health = 100
	entity.current_health = 100
	entity.max_mana = 50
	entity.current_mana = 50
	entity.current_speed = 200.0

	add_child(entity)
	await get_tree().process_frame  # Wait for _ready to complete

	print("✅ BaseEntity created: ", entity.entity_name)
	print("💚 Health: ", entity.current_health, "/", entity.max_health)
	print("🔮 Mana: ", entity.current_mana, "/", entity.max_mana)
	print("🏃 Speed: ", entity.current_speed)

	# Test health system
	print("\n🧪 Testing Health System...")
	if entity.has_method("take_damage"):
		entity.take_damage(30)
		print("💥 After 30 damage - Health: ", entity.current_health, "/", entity.max_health)

	if entity.has_method("heal"):
		entity.heal(15)
		print("💚 After 15 healing - Health: ", entity.current_health, "/", entity.max_health)

	# Test mana system
	print("\n🧪 Testing Mana System...")
	if entity.has_method("use_mana"):
		var mana_used = entity.use_mana(20)
		print("🔮 Used 20 mana - Success: ", mana_used, " - Mana: ", entity.current_mana, "/", entity.max_mana)

	if entity.has_method("restore_mana"):
		entity.restore_mana(10)
		print("� Restored 10 mana - Mana: ", entity.current_mana, "/", entity.max_mana)

	# Test ability system
	print("\n🧪 Testing Ability System...")
	if entity.has_method("load_ability"):
		entity.load_ability("blink")
		print("⚡ Loaded blink ability")

	if entity.has_method("use_ability"):
		var ability_used = entity.use_ability("blink")
		print("✨ Used blink ability - Success: ", ability_used)

func test_player_creation():
	"""Test Player creation with modular system"""
	print("\n🎮 === TESTING PLAYER CREATION ===")

	var player_script = load("res://components/Player.gd")
	if not player_script:
		print("❌ Player script failed to load")
		return

	var player = player_script.new()
	player.name = "TestPlayer"
	add_child(player)
	await get_tree().process_frame  # Wait for _ready to complete

	print("✅ Player created successfully")
	print("🎮 Player name: ", player.entity_name)
	print("💚 Player health: ", player.current_health, "/", player.max_health)
	print("🔮 Player mana: ", player.current_mana, "/", player.max_mana)
	print("🎯 Player score: ", player.get_score())
	print("💔 Player lives: ", player.get_lives())

	# Test player-specific functions
	print("\n🧪 Testing Player Functions...")
	player.add_score(100)
	print("🎯 After adding 100 points - Score: ", player.get_score())

	player.lose_life()
	print("💔 After losing life - Lives: ", player.get_lives())

	# Test inherited functions
	player.take_damage(25)
	print("💥 After 25 damage - Health: ", player.current_health, "/", player.max_health)

	var blink_used = player.use_ability("blink")
	print("✨ Used blink ability - Success: ", blink_used)