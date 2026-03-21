extends Node
class_name HealthComponent

# ===== SIGNALS =====
signal health_changed(new_health: int, max_health: int)
signal entity_died(entity: Node)
signal damage_taken(amount: int, source: Node)
signal healed(amount: int)

# ===== REFERENCES =====
var entity: Node
@export var health_stats: HealthStats

var max_health: int = 100
var current_health: int = 100
var armor: int = 0
var status_effect_manager: StatusEffectManager

# ===== SETUP =====
func setup(parent_entity: Node, stats: HealthStats = null):
	"""Initialize the component with parent entity"""
	entity = parent_entity
	name = "HealthComponent"
	_configure_stats(stats)
	_ensure_status_effect_manager()
	_sync_entity_health_state()
	print("💚 HealthComponent setup for: ", entity.entity_name)

func _configure_stats(stats: HealthStats = null) -> void:
	if stats != null:
		health_stats = stats
	if health_stats == null:
		var default_stats_resource := load("res://resources/stats/DefaultHealthStats.tres")
		if default_stats_resource is HealthStats:
			health_stats = default_stats_resource
		else:
			health_stats = HealthStats.new()
			health_stats.max_health = int(entity.get("max_health")) if entity != null else 100
			health_stats.base_armor = int(entity.get("armor")) if entity != null else 0
			health_stats.regen_per_second = float(entity.get("health_regen")) if entity != null else 0.0

	max_health = max(1, health_stats.max_health)
	armor = max(0, health_stats.base_armor)
	if entity != null and entity.get("current_health") != null:
		current_health = clampi(int(entity.get("current_health")), 0, max_health)
	else:
		current_health = max_health

func _ensure_status_effect_manager() -> void:
	if has_node("StatusEffectManager"):
		status_effect_manager = $StatusEffectManager
	else:
		var status_script = load("res://components/StatusEffectManager.gd")
		status_effect_manager = status_script.new()
		status_effect_manager.name = "StatusEffectManager"
		add_child(status_effect_manager)
	if status_effect_manager != null and status_effect_manager.has_method("setup"):
		status_effect_manager.setup(self)

func _sync_entity_health_state() -> void:
	if entity == null:
		return
	entity.set("max_health", max_health)
	entity.set("current_health", current_health)
	entity.set("armor", armor)
	if health_stats != null:
		entity.set("health_regen", int(round(health_stats.regen_per_second)))

# ===== DAMAGE SYSTEM =====
func take_damage(amount: int, source: Node = null):
	"""Apply damage to the entity"""
	if not is_alive():
		return

	# Calculate damage after armor
	var actual_damage = max(1, amount - armor)  # Minimum 1 damage

	# Apply damage
	current_health = max(0, current_health - actual_damage)
	_sync_entity_health_state()

	print("💥 ", entity.entity_name, " took ", actual_damage, " damage (", amount, " - ", armor, " armor)")
	print("💚 Health: ", current_health, "/", max_health)

	# Emit signals
	health_changed.emit(current_health, max_health)
	damage_taken.emit(actual_damage, source)

	# Check for death
	if current_health <= 0:
		current_health = 0
		_sync_entity_health_state()
		die()

func heal(amount: int):
	"""Heal the entity"""
	if not is_alive():
		return

	var old_health = current_health
	current_health = min(current_health + amount, max_health)
	var actual_heal = current_health - old_health
	_sync_entity_health_state()

	if actual_heal > 0:
		print("💚 ", entity.entity_name, " healed for ", actual_heal, " HP")
		print("💚 Health: ", current_health, "/", max_health)

		health_changed.emit(current_health, max_health)
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
	if max_health <= 0:
		return 0.0
	return float(current_health) / float(max_health)

func is_at_full_health() -> bool:
	"""Check if entity is at full health"""
	return current_health >= max_health

func is_critical_health(threshold: float = 0.25) -> bool:
	"""Check if health is below critical threshold"""
	return get_health_percentage() <= threshold

func set_max_health(new_max: int):
	"""Set new maximum health"""
	var health_percentage = get_health_percentage()
	max_health = max(1, new_max)
	current_health = int(max_health * health_percentage)
	_sync_entity_health_state()
	health_changed.emit(current_health, max_health)

func set_current_health(new_health: int):
	"""Set current health directly"""
	current_health = min(max(0, new_health), max_health)
	_sync_entity_health_state()
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		die()

func is_alive() -> bool:
	return current_health > 0

func get_current_health() -> int:
	return current_health

func get_max_health() -> int:
	return max_health

func get_status_effect_manager() -> StatusEffectManager:
	return status_effect_manager

# ===== STATUS EFFECTS =====
func apply_poison(damage_per_second: float, duration: float):
	"""Delegate poison to StatusEffectManager"""
	if status_effect_manager and status_effect_manager.has_method("apply_poison"):
		status_effect_manager.apply_poison(damage_per_second, duration)

func apply_regeneration(heal_per_second: float, duration: float):
	"""Delegate regeneration to StatusEffectManager"""
	if status_effect_manager and status_effect_manager.has_method("apply_regeneration"):
		status_effect_manager.apply_regeneration(heal_per_second, duration)