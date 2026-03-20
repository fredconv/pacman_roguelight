extends "res://core/entity/components/states/BaseState.gd"

func update(_delta: float) -> void:
	if entity == null:
		return
	if not entity.has_method("get_threat_position"):
		return
	var threat: Vector2 = entity.get_threat_position()
	if entity.has_method("move_away_from"):
		entity.move_away_from(threat)
