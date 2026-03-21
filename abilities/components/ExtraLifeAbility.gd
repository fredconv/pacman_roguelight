extends "res://abilities/AbilityComponent.gd"

var current_bonus: int = 0

func _apply_stats(stats: Resource) -> void:
	if stats == null:
		return
	var new_bonus := int(stats.extra_lives)
	var delta := new_bonus - current_bonus
	current_bonus = new_bonus
	if delta != 0 and owner_entity != null and owner_entity.has_method("add_extra_lives"):
		owner_entity.add_extra_lives(delta)
