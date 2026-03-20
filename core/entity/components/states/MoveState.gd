extends "res://core/entity/components/states/BaseState.gd"

func update(_delta: float) -> void:
	if entity == null:
		return
	if entity.has_method("get_desired_direction") and entity.has_method("set_move_direction"):
		var dir: Vector2 = entity.get_desired_direction()
		entity.set_move_direction(dir)
