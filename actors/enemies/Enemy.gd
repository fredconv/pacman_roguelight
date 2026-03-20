extends Entity

@export var target_path: NodePath

@onready var enemy_ai_component: Node = $EnemyAIComponent

func _ready() -> void:
	if stats_resource == null:
		stats_resource = preload("res://resources/stats/EnemyStats_Chaser.tres")
	super._ready()
	if enemy_ai_component and enemy_ai_component.has_method("setup"):
		enemy_ai_component.setup(self)
	add_to_group("enemy")
	set_state("ChaseState")

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if enemy_ai_component and enemy_ai_component.has_method("update_ai"):
		var target := get_node_or_null(target_path)
		if target:
			enemy_ai_component.update_ai(target)

func get_target_position() -> Vector2:
	var target := get_node_or_null(target_path)
	if target and target is Node2D:
		return target.global_position
	return global_position

func move_towards(target_position: Vector2) -> void:
	var dir := (target_position - global_position).normalized()
	set_move_direction(dir)

func get_threat_position() -> Vector2:
	return get_target_position()

func move_away_from(threat_position: Vector2) -> void:
	var dir := (global_position - threat_position).normalized()
	set_move_direction(dir)
