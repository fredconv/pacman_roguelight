extends Node
class_name BlinkAbility

# ===== ABILITY PROPERTIES =====
const ABILITY_NAME = "blink"
const DESCRIPTION = "Teleport a short distance in the direction you're facing"
const MANA_COST = 20
const COOLDOWN = 5.0
const BLINK_DISTANCE = 100.0

# ===== ABILITY METHODS =====
func get_description() -> String:
	return DESCRIPTION

func get_mana_cost() -> int:
	return MANA_COST

func get_cooldown() -> float:
	return COOLDOWN

func execute(entity: CharacterBody2D):
	"""Execute the blink ability"""
	print("✨ Executing Blink for: ", entity.name)

	# Get movement direction (you might want to use entity's facing direction)
	var direction = Vector2.RIGHT  # Default direction

	# Try to get current movement direction from MovementComponent
	var movement_component = entity.get_node_or_null("MovementComponent")
	if movement_component and movement_component.has_method("get_current_direction"):
		var current_dir = movement_component.get_current_direction()
		if current_dir.length() > 0:
			direction = current_dir

	# Calculate blink destination
	var start_position = entity.global_position
	var end_position = start_position + direction.normalized() * BLINK_DISTANCE

	# Check if blink destination is valid (you might want to add collision checking)
	if can_blink_to(entity, end_position):
		# Perform the blink
		entity.global_position = end_position
		print("⚡ Blinked from ", start_position, " to ", end_position)

		# Add visual effects here if desired
		create_blink_effect(start_position, end_position)
	else:
		print("❌ Cannot blink to position: ", end_position)

func can_blink_to(entity: CharacterBody2D, position: Vector2) -> bool:
	"""Check if the blink destination is valid"""
	# For now, just check if it's within reasonable bounds
	# You could add collision checking, boundary checking, etc.

	# Simple bounds check (adjust as needed)
	var viewport_size = entity.get_viewport().get_visible_rect().size
	if position.x < 0 or position.x > viewport_size.x:
		return false
	if position.y < 0 or position.y > viewport_size.y:
		return false

	return true

func create_blink_effect(start_pos: Vector2, end_pos: Vector2):
	"""Create visual effects for the blink"""
	print("✨ Blink effect from ", start_pos, " to ", end_pos)
	# Here you could:
	# - Spawn particles
	# - Play sound effects
	# - Create temporary sprites
	# - etc.