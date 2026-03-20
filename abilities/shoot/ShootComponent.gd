extends Node

@export var shoot_stats: ShootStats
@export var projectile_scene: PackedScene = preload("res://abilities/shoot/Projectile.tscn")

var owner_entity: Node2D
var cooldown_ready: bool = true

func setup(entity: Node2D) -> void:
	owner_entity = entity
	if shoot_stats == null:
		shoot_stats = preload("res://abilities/shoot/ShootStats.tres")

func try_shoot(direction: Vector2) -> bool:
	if owner_entity == null or not cooldown_ready:
		return false
	if projectile_scene == null or direction == Vector2.ZERO:
		return false
	cooldown_ready = false
	var projectile := projectile_scene.instantiate()
	projectile.global_position = owner_entity.global_position
	projectile.direction = direction.normalized()
	projectile.speed = shoot_stats.projectile_speed
	projectile.damage = shoot_stats.projectile_damage
	owner_entity.get_tree().current_scene.add_child(projectile)
	await get_tree().create_timer(shoot_stats.cooldown_seconds).timeout
	cooldown_ready = true
	return true
