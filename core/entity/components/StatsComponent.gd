extends Node

@export var stats: EntityStats

var current_health: int = 0

signal stats_ready(stats_resource: EntityStats)
signal current_health_changed(current: int, maximum: int)

func setup(default_stats: EntityStats) -> void:
	if stats == null:
		stats = default_stats
	if stats == null:
		stats = EntityStats.new()
	current_health = stats.max_health
	stats_ready.emit(stats)
	current_health_changed.emit(current_health, stats.max_health)

func get_max_health() -> int:
	return stats.max_health if stats != null else 0

func get_base_speed() -> float:
	return stats.base_speed if stats != null else 0.0

func get_base_damage() -> int:
	return stats.base_damage if stats != null else 0

func get_armor() -> int:
	return stats.armor if stats != null else 0

func set_current_health(value: int) -> void:
	current_health = clampi(value, 0, get_max_health())
	current_health_changed.emit(current_health, get_max_health())
