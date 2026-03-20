extends Node

@export var dash_stats: DashStats

var owner_entity: Node2D
var cooldown_ready: bool = true

func setup(entity: Node2D) -> void:
	owner_entity = entity
	if dash_stats == null:
		dash_stats = preload("res://abilities/dash/DashStats.tres")

func try_dash(direction: Vector2) -> bool:
	if owner_entity == null or not cooldown_ready:
		return false
	if direction == Vector2.ZERO:
		return false
	cooldown_ready = false
	var from := owner_entity.global_position
	var to := from + direction.normalized() * dash_stats.dash_distance
	var tween := create_tween()
	tween.tween_property(owner_entity, "global_position", to, dash_stats.dash_duration)
	await get_tree().create_timer(dash_stats.cooldown_seconds).timeout
	cooldown_ready = true
	return true
