extends "res://abilities/AbilityComponent.gd"

var dash_cells: int = 0

func _apply_stats(stats: Resource) -> void:
	if stats == null:
		return
	dash_cells = int(stats.dash_cells)

func get_input_action() -> StringName:
	return &"dash"

func can_activate() -> bool:
	return owner_entity != null and dash_cells > 0 and owner_entity.has_method("dash_forward")

func activate() -> bool:
	if not can_activate():
		return false
	var did_dash: bool = owner_entity.dash_forward(dash_cells)
	if did_dash:
		ability_activated.emit(ability_id)
	return did_dash
