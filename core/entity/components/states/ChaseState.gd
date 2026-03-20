extends "res://core/entity/components/states/BaseState.gd"

func update(_delta: float) -> void:
	if entity == null:
		return
	if not entity.has_method("get_target_position"):
		return
	var target: Vector2 = entity.get_target_position()
	if entity.has_method("move_towards"):
		entity.move_towards(target)
