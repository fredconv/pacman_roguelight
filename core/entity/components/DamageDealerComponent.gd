extends Node

@export var damage_amount: int = 5

func deal_to(target: Node) -> void:
	if target == null:
		return
	if target.has_method("receive_damage"):
		target.receive_damage(damage_amount, get_parent())
		return
	if target.has_meta("damage_receiver") and target.has_method("receive_damage"):
		target.receive_damage(damage_amount, get_parent())
