extends Node

@export var detection_range: float = 280.0

var owner_enemy: Node

func setup(enemy: Node) -> void:
	owner_enemy = enemy

func update_ai(target: Node2D) -> void:
	if owner_enemy == null or target == null:
		return
	var dist := owner_enemy.global_position.distance_to(target.global_position)
	if dist <= detection_range:
		owner_enemy.set_state("ChaseState")
	else:
		owner_enemy.set_state("IdleState")
