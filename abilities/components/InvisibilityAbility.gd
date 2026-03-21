extends "res://abilities/AbilityComponent.gd"

var duration_seconds: float = 0.0

func _apply_stats(stats: Resource) -> void:
	if stats == null:
		return
	duration_seconds = float(stats.duration_seconds)
