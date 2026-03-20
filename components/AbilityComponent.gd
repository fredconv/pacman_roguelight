extends Node
class_name AbilityComponent

# ===== SIGNALS =====
signal ability_used(ability_name: String)
signal ability_cooldown_started(ability_name: String, duration: float)
signal ability_ready(ability_name: String)

# ===== REFERENCES =====
var entity: CharacterBody2D
var loaded_abilities: Dictionary = {}
var ability_cooldowns: Dictionary = {}

# ===== SETUP =====
func setup(parent_entity: CharacterBody2D):
	"""Initialize the component with parent entity"""
	entity = parent_entity
	name = "AbilityComponent"
	print("⚡ AbilityComponent setup for: ", entity.name)

# ===== ABILITY MANAGEMENT =====
func load_ability(ability_name: String):
	"""Load an ability script"""
	var ability_path = "res://scenes/abilities/" + ability_name + ".gd"

	if ResourceLoader.exists(ability_path):
		var ability_script = load(ability_path)
		var ability_instance = ability_script.new()

		loaded_abilities[ability_name] = ability_instance
		ability_cooldowns[ability_name] = 0.0

		print("✅ Ability loaded: ", ability_name)
	else:
		print("❌ Ability not found: ", ability_path)

func use_ability(ability_name: String) -> bool:
	"""Try to use an ability"""
	# Check if ability exists
	if not loaded_abilities.has(ability_name):
		print("❌ Ability not loaded: ", ability_name)
		return false

	# Check cooldown
	if is_on_cooldown(ability_name):
		print("❌ Ability on cooldown: ", ability_name, " (", ability_cooldowns[ability_name], "s remaining)")
		return false

	# Check mana cost
	var ability = loaded_abilities[ability_name]
	if ability.has_method("get_mana_cost"):
		var mana_cost = ability.get_mana_cost()
		if entity.current_mana < mana_cost:
			print("❌ Not enough mana for: ", ability_name, " (need ", mana_cost, ", have ", entity.current_mana, ")")
			return false

		# Use mana
		entity.current_mana -= mana_cost

	# Execute ability
	if ability.has_method("execute"):
		ability.execute(entity)

		# Start cooldown
		if ability.has_method("get_cooldown"):
			var cooldown_duration = ability.get_cooldown()
			start_cooldown(ability_name, cooldown_duration)

		print("⚡ Ability used: ", ability_name)
		ability_used.emit(ability_name)
		return true

	print("❌ Ability has no execute method: ", ability_name)
	return false

# ===== COOLDOWN SYSTEM =====
func start_cooldown(ability_name: String, duration: float):
	"""Start cooldown for an ability"""
	ability_cooldowns[ability_name] = duration
	ability_cooldown_started.emit(ability_name, duration)

	# Create a timer to track when ability is ready
	var timer = get_tree().create_timer(duration)
	timer.timeout.connect(_on_ability_ready.bind(ability_name))

func _on_ability_ready(ability_name: String):
	"""Called when ability cooldown is finished"""
	ability_ready.emit(ability_name)
	print("✅ Ability ready: ", ability_name)

func is_on_cooldown(ability_name: String) -> bool:
	"""Check if ability is on cooldown"""
	if not ability_cooldowns.has(ability_name):
		return false
	return ability_cooldowns[ability_name] > 0.0

func get_cooldown_remaining(ability_name: String) -> float:
	"""Get remaining cooldown time"""
	if ability_cooldowns.has(ability_name):
		return max(0.0, ability_cooldowns[ability_name])
	return 0.0

# ===== UPDATE COOLDOWNS =====
func _process(delta: float):
	"""Update ability cooldowns"""
	for ability_name in ability_cooldowns.keys():
		if ability_cooldowns[ability_name] > 0.0:
			ability_cooldowns[ability_name] -= delta
			ability_cooldowns[ability_name] = max(0.0, ability_cooldowns[ability_name])

# ===== UTILITY FUNCTIONS =====
func get_loaded_abilities() -> Array:
	"""Get list of loaded abilities"""
	return loaded_abilities.keys()

func has_ability(ability_name: String) -> bool:
	"""Check if ability is loaded"""
	return loaded_abilities.has(ability_name)

func remove_ability(ability_name: String):
	"""Remove an ability"""
	if loaded_abilities.has(ability_name):
		loaded_abilities.erase(ability_name)
		ability_cooldowns.erase(ability_name)
		print("🗑️ Ability removed: ", ability_name)

func clear_all_abilities():
	"""Remove all abilities"""
	loaded_abilities.clear()
	ability_cooldowns.clear()
	print("🗑️ All abilities cleared")

# ===== ABILITY INFO =====
func get_ability_info(ability_name: String) -> Dictionary:
	"""Get information about an ability"""
	if not loaded_abilities.has(ability_name):
		return {}

	var ability = loaded_abilities[ability_name]
	var info = {
		"name": ability_name,
		"cooldown_remaining": get_cooldown_remaining(ability_name),
		"on_cooldown": is_on_cooldown(ability_name)
	}

	# Get additional info if methods exist
	if ability.has_method("get_description"):
		info.description = ability.get_description()
	if ability.has_method("get_mana_cost"):
		info.mana_cost = ability.get_mana_cost()
	if ability.has_method("get_cooldown"):
		info.cooldown = ability.get_cooldown()

	return info