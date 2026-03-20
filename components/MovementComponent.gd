extends Node
class_name MovementComponent

# ===== SIGNALS =====
signal movement_started()
signal movement_stopped()
signal direction_changed(new_direction: Vector2)

# ===== REFERENCES =====
var entity: CharacterBody2D
var current_direction: Vector2 = Vector2.ZERO
var is_moving: bool = false

# ===== SETUP =====
func setup(parent_entity: CharacterBody2D):
	"""Initialize the component with parent entity"""
	entity = parent_entity
	name = "MovementComponent"
	print("🏃 MovementComponent setup for: ", entity.name)

# ===== MOVEMENT FUNCTIONS =====
func move_towards(direction: Vector2, _delta: float):
	"""Move entity in given direction"""
	if not entity:
		return

	# Normalize direction
	direction = direction.normalized()

	# Check if direction changed
	if direction != current_direction:
		current_direction = direction
		direction_changed.emit(direction)

	# Check movement state
	var was_moving = is_moving
	is_moving = direction.length() > 0

	if is_moving and not was_moving:
		movement_started.emit()
	elif not is_moving and was_moving:
		movement_stopped.emit()

	# Apply movement
	if is_moving:
		entity.velocity = direction * entity.current_speed
	else:
		entity.velocity = Vector2.ZERO

	# Move the entity
	entity.move_and_slide()

func set_speed(new_speed: float):
	"""Set movement speed"""
	if entity:
		entity.current_speed = new_speed

func stop():
	"""Stop all movement"""
	current_direction = Vector2.ZERO
	is_moving = false
	if entity:
		entity.velocity = Vector2.ZERO
	movement_stopped.emit()

func move_to_position(target_position: Vector2, speed_multiplier: float = 1.0):
	"""Move directly to a position"""
	if not entity:
		return

	var direction = (target_position - entity.global_position).normalized()
	var distance = entity.global_position.distance_to(target_position)

	# If close enough, snap to position
	if distance < 5.0:
		entity.global_position = target_position
		stop()
		return

	# Move towards target
	entity.velocity = direction * entity.current_speed * speed_multiplier
	entity.move_and_slide()

# ===== UTILITY FUNCTIONS =====
func get_current_direction() -> Vector2:
	"""Get current movement direction"""
	return current_direction

func get_movement_speed() -> float:
	"""Get current movement speed"""
	return entity.velocity.length()

func is_entity_moving() -> bool:
	"""Check if entity is currently moving"""
	return is_moving

# ===== ADVANCED MOVEMENT =====
func dash(direction: Vector2, distance: float, duration: float):
	"""Perform a dash movement"""
	var start_pos = entity.global_position
	var end_pos = start_pos + direction.normalized() * distance

	var tween = create_tween()
	tween.tween_method(_update_dash_position, start_pos, end_pos, duration)

	print("💨 Dashing from ", start_pos, " to ", end_pos)

func _update_dash_position(position: Vector2):
	"""Update position during dash"""
	if entity:
		entity.global_position = position

func knockback(direction: Vector2, force: float, duration: float):
	"""Apply knockback effect"""
	var knockback_velocity = direction.normalized() * force

	var tween = create_tween()
	tween.tween_method(_apply_knockback, knockback_velocity, Vector2.ZERO, duration)

func _apply_knockback(velocity: Vector2):
	"""Apply knockback velocity"""
	if entity:
		entity.velocity += velocity

func teleport_to(position: Vector2):
	"""Instantly teleport to position"""
	if entity:
		entity.global_position = position
		stop()
		print("✨ Teleported to: ", position)

# ===== COLLISION HELPERS =====
func can_move_to(_position: Vector2) -> bool:
	"""Check if entity can move to a position"""
	# This would need to be implemented based on your collision system
	# For now, just return true
	return true

func get_collision_normal() -> Vector2:
	"""Get the normal of the last collision"""
	if entity and entity.get_slide_collision_count() > 0:
		var collision = entity.get_slide_collision(0)
		return collision.get_normal()
	return Vector2.ZERO