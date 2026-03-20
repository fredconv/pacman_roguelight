extends Node

@export var receiver_tag: String = "damage_receiver"

var health_component: Node

func setup(health: Node) -> void:
	health_component = health
	set_meta(receiver_tag, true)

func receive_damage(amount: int, source: Node = null) -> void:
	if health_component == null:
		return
	if health_component.has_method("apply_damage"):
		health_component.apply_damage(amount, source)
