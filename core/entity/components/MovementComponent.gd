extends Node

signal direction_changed(direction: Vector2)

var owner_entity: CharacterBody2D
var move_direction: Vector2 = Vector2.ZERO

func setup(entity: CharacterBody2D) -> void:
	owner_entity = entity

func set_direction(direction: Vector2) -> void:
	move_direction = direction.normalized()
	direction_changed.emit(move_direction)

func physics_step(delta: float, speed: float) -> void:
	if owner_entity == null:
		return
	owner_entity.velocity = move_direction * speed
	owner_entity.move_and_slide()
