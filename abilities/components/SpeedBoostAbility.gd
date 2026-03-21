extends "res://abilities/AbilityComponent.gd"

var current_multiplier: float = 0.0

func _apply_stats(stats: Resource) -> void:
	if stats == null:
		return
	current_multiplier = float(stats.speed_multiplier)
	if owner_entity != null and owner_entity.has_method("set_speed_bonus_multiplier"):
		owner_entity.set_speed_bonus_multiplier(current_multiplier)
