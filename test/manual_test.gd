# Manual test script - run this in Godot's script editor
extends Node

func _ready():
	manual_test()

func manual_test():
	print("🧪 === MANUAL TEST START ===")

	# Test 1: Load scripts
	print("📂 Loading scripts...")

	var base_entity_script = load("res://components/BaseEntity.gd")
	print("BaseEntity loaded: ", base_entity_script != null)

	var health_script = load("res://components/HealthComponent.gd")
	print("HealthComponent loaded: ", health_script != null)

	var movement_script = load("res://components/MovementComponent.gd")
	print("MovementComponent loaded: ", movement_script != null)

	var ability_script = load("res://components/AbilityComponent.gd")
	print("AbilityComponent loaded: ", ability_script != null)

	var player_script = load("res://components/Player.gd")
	print("Player loaded: ", player_script != null)

	var blink_script = load("res://scenes/abilities/blink.gd")
	print("Blink ability loaded: ", blink_script != null)

	print("\n✅ === MANUAL TEST COMPLETED ===")

	if base_entity_script and health_script and movement_script and ability_script and player_script:
		print("🎉 ALL SCRIPTS LOADED SUCCESSFULLY!")
		print("✅ The modular system is ready to use!")
	else:
		print("❌ Some scripts failed to load - check paths and syntax")