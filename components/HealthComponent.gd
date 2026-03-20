extends Node
class_name HealthComponent

# ===== SIGNALS =====
signal health_changed(new_health: int, max_health: int)
signal entity_died(entity: Node)
signal damage_taken(amount: int, source: Node)
signal healed(amount: int)

# ===== REFERENCES =====
var entity: Node

# ===== SETUP =====
func setup(parent_entity: Node):
	"""Initialize the component with parent entity"""
	entity = parent_entity
	name = "HealthComponent"
	print("💚 HealthComponent setup for: ", entity.entity_name)

# ===== DAMAGE SYSTEM =====
func take_damage(amount: int, source: Node = null):
	"""Apply damage to the entity"""
	if not entity or not entity.is_alive():
		return

	# Calculate damage after armor
	var actual_damage = max(1, amount - entity.armor)  # Minimum 1 damage

	# Apply damage
	entity.current_health = max(0, entity.current_health - actual_damage)

	print("💥 ", entity.entity_name, " took ", actual_damage, " damage (", amount, " - ", entity.armor, " armor)")
	print("💚 Health: ", entity.current_health, "/", entity.max_health)

	# Emit signals
	health_changed.emit(entity.current_health, entity.max_health)
	damage_taken.emit(actual_damage, source)

	# Check for death
	if entity.current_health <= 0:
		die()

func heal(amount: int):
	"""Heal the entity"""
	if not entity or not entity.is_alive():
		return

	var old_health = entity.current_health
	entity.current_health = min(entity.current_health + amount, entity.max_health)
	var actual_heal = entity.current_health - old_health

	if actual_heal > 0:
		print("💚 ", entity.entity_name, " healed for ", actual_heal, " HP")
		print("💚 Health: ", entity.current_health, "/", entity.max_health)

		health_changed.emit(entity.current_health, entity.max_health)
		healed.emit(actual_heal)

func die():
	"""Handle entity death"""
	print("💀 ", entity.entity_name, " has died!")
	entity_died.emit(entity)

	# You can add death effects here:
	# - Play death animation
	# - Spawn particles
	# - Drop items
	# - etc.

# ===== UTILITY FUNCTIONS =====
func get_health_percentage() -> float:
	"""Get health as percentage (0.0 to 1.0)"""
	if entity.max_health <= 0:
		return 0.0
	return float(entity.current_health) / float(entity.max_health)

func is_at_full_health() -> bool:
	"""Check if entity is at full health"""
	return entity.current_health >= entity.max_health

func is_critical_health(threshold: float = 0.25) -> bool:
	"""Check if health is below critical threshold"""
	return get_health_percentage() <= threshold

func set_max_health(new_max: int):
	"""Set new maximum health"""
	var health_percentage = get_health_percentage()
	entity.max_health = new_max
	entity.current_health = int(new_max * health_percentage)
	health_changed.emit(entity.current_health, entity.max_health)

func set_current_health(new_health: int):
	"""Set current health directly"""
	entity.current_health = min(max(0, new_health), entity.max_health)
	health_changed.emit(entity.current_health, entity.max_health)

	if entity.current_health <= 0:
		die()

# ===== STATUS EFFECTS =====
func apply_poison(damage_per_second: float, duration: float):
	"""Apply poison effect"""
	var total_ticks = int(duration)

	for i in range(total_ticks):
		await get_tree().create_timer(1.0).timeout
		if entity and entity.is_alive():
			take_damage(int(damage_per_second))
			print("🐍 Poison damage: ", damage_per_second)

func apply_regeneration(heal_per_second: float, duration: float):
	"""Apply regeneration effect"""
	var total_ticks = int(duration)

	for i in range(total_ticks):
		await get_tree().create_timer(1.0).timeout
		if entity and entity.is_alive():
			heal(int(heal_per_second))
			print("✨ Regeneration: ", heal_per_second)