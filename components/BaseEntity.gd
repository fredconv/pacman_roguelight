extends CharacterBody2D
class_name BaseEntity

# ===== CORE PROPERTIES =====
@export var entity_name: String = "Entity"

# ===== HEALTH SYSTEM =====
@export var max_health: int = 100
@export var current_health: int = 100
@export var health_regen: int = 1
@export var armor: int = 0

# ===== MANA SYSTEM =====
@export var max_mana: int = 100
@export var current_mana: int = 100
@export var mana_regen: int = 1

# ===== MOVEMENT SYSTEM =====
@export var max_speed: float = 200.0
@export var current_speed: float = 0.0
@export var acceleration: float = 4.0

# ===== ABILITY SYSTEM =====
@export var agility: int = 1
@export var global_cooldown: float = 30.0
@export var is_busy: bool = false
@export var last_ability: int = 0

# ===== SIGNALS =====
signal health_changed(new_health: int, max_health: int)
signal mana_changed(new_mana: int, max_mana: int)
signal entity_died(entity: Node)
signal ability_used(ability_name: String)

# ===== COMPONENTS REFERENCES =====
var health_component: Node
var movement_component: Node
var ability_component: Node

func _ready():
	print("🏗️ BaseEntity initialized: ", entity_name)
	setup_components()
	connect_signals()

func setup_components():
	"""Initialize and setup all components"""
	# Create HealthComponent
	var health_script = load("res://components/HealthComponent.gd")
	health_component = health_script.new()
	health_component.setup(self)
	add_child(health_component)

	# Create MovementComponent
	var movement_script = load("res://components/MovementComponent.gd")
	movement_component = movement_script.new()
	movement_component.setup(self)
	add_child(movement_component)	# Create AbilityComponent
	var ability_script = load("res://components/AbilityComponent.gd")
	ability_component = ability_script.new()
	ability_component.setup(self)
	add_child(ability_component)

	print("✅ Components setup complete for: ", entity_name)

func connect_signals():
	"""Connect component signals to entity"""
	if health_component:
		health_component.health_changed.connect(_on_health_changed)
		health_component.entity_died.connect(_on_entity_died)

	if ability_component:
		ability_component.ability_used.connect(_on_ability_used)

# ===== HEALTH FUNCTIONS =====
func take_damage(amount: int, source: BaseEntity = null):
	"""Deal damage to this entity"""
	if health_component:
		health_component.take_damage(amount, source)

func heal(amount: int):
	"""Heal this entity"""
	if health_component:
		health_component.heal(amount)

func is_alive() -> bool:
	"""Check if entity is alive"""
	return current_health > 0

# ===== MANA FUNCTIONS =====
func use_mana(amount: int) -> bool:
	"""Try to use mana, returns true if successful"""
	if current_mana >= amount:
		current_mana -= amount
		mana_changed.emit(current_mana, max_mana)
		return true
	return false

func restore_mana(amount: int):
	"""Restore mana"""
	current_mana = min(current_mana + amount, max_mana)
	mana_changed.emit(current_mana, max_mana)

# ===== MOVEMENT FUNCTIONS =====
func move_towards(direction: Vector2, delta: float):
	"""Move entity in given direction"""
	if movement_component:
		movement_component.move_towards(direction, delta)

func set_speed(new_speed: float):
	"""Set entity speed"""
	current_speed = new_speed
	if movement_component:
		movement_component.set_speed(new_speed)

# ===== ABILITY FUNCTIONS =====
func use_ability(ability_name: String) -> bool:
	"""Try to use an ability"""
	if ability_component and not is_busy:
		return ability_component.use_ability(ability_name)
	return false

func load_ability(ability_name: String):
	"""Load an ability into the system"""
	if ability_component:
		ability_component.load_ability(ability_name)

# ===== REGENERATION SYSTEM =====
func _physics_process(delta: float):
	# Health regeneration
	if current_health < max_health and health_regen > 0:
		heal(int(health_regen * delta))

	# Mana regeneration
	if current_mana < max_mana and mana_regen > 0:
		restore_mana(int(mana_regen * delta))

	# Update global cooldown
	if global_cooldown > 0:
		global_cooldown -= delta * 60.0  # Convert to "per second"

# ===== SIGNAL HANDLERS =====
func _on_health_changed(new_health: int, max_health_val: int):
	current_health = new_health
	health_changed.emit(new_health, max_health_val)

func _on_entity_died(_entity: BaseEntity):
	print("💀 Entity died: ", entity_name)
	entity_died.emit(self)

func _on_ability_used(ability_name: String):
	print("⚡ Ability used: ", ability_name)
	ability_used.emit(ability_name)

# ===== UTILITY FUNCTIONS =====
func get_health_percentage() -> float:
	return float(current_health) / float(max_health)

func get_mana_percentage() -> float:
	return float(current_mana) / float(max_mana)

func is_full_health() -> bool:
	return current_health >= max_health

func is_full_mana() -> bool:
	return current_mana >= max_mana