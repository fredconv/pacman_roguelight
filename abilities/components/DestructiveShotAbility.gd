extends "res://abilities/AbilityComponent.gd"

var stun_seconds: float = 0.0

func _apply_stats(stats: Resource) -> void:
	if stats == null:
		return
	stun_seconds = float(stats.stun_seconds)
