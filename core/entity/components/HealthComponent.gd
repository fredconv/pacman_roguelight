extends Node

signal health_changed(current: int, maximum: int)
signal died(entity: Node)

var owner_entity: Node
var stats_component: Node

func setup(entity: Node, stats: Node) -> void:
	owner_entity = entity
	stats_component = stats
	if stats_component and stats_component.has_signal("current_health_changed"):
		stats_component.current_health_changed.connect(_on_stats_health_changed)
	if stats_component:
		health_changed.emit(stats_component.current_health, stats_component.get_max_health())

func apply_damage(amount: int, _source: Node = null) -> void:
	if stats_component == null:
		return
	var armor := stats_component.get_armor() if stats_component.has_method("get_armor") else 0
	var final_damage := maxi(1, amount - armor)
	stats_component.set_current_health(stats_component.current_health - final_damage)
	if stats_component.current_health <= 0:
		died.emit(owner_entity)

func heal(amount: int) -> void:
	if stats_component == null:
		return
	stats_component.set_current_health(stats_component.current_health + amount)

func _on_stats_health_changed(current: int, maximum: int) -> void:
	health_changed.emit(current, maximum)
