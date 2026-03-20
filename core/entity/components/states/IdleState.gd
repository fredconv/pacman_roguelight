extends "res://core/entity/components/states/BaseState.gd"

func enter() -> void:
	if entity and entity.has_method("set_move_direction"):
		entity.set_move_direction(Vector2.ZERO)
