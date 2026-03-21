extends "res://abilities/AbilityComponent.gd"

var max_mines: int = 0

func _apply_stats(stats: Resource) -> void:
	if stats == null:
		return
	max_mines = int(stats.max_mines)
