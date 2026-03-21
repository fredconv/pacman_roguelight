extends Node

signal ability_applied(ability_id: StringName, level: int)
signal ability_upgraded(ability_id: StringName, level: int)
signal ability_activated(ability_id: StringName)

var owner_entity: CharacterBody2D
var ability_data: AbilityData
var ability_id: StringName = &""
var level: int = 0
var max_level: int = 3

func setup(entity: CharacterBody2D, data: AbilityData) -> void:
	owner_entity = entity
	apply_data(data)

func apply_data(data: AbilityData) -> void:
	ability_data = data
	ability_id = data.id
	level = data.level
	max_level = data.max_level
	_apply_stats(data.stats)
	ability_applied.emit(ability_id, level)

func upgrade(data: AbilityData) -> void:
	apply_data(data)
	ability_upgraded.emit(ability_id, level)

func get_input_action() -> StringName:
	return &""

func can_activate() -> bool:
	return false

func activate() -> bool:
	if not can_activate():
		return false
	ability_activated.emit(ability_id)
	return true

func _apply_stats(_stats: Resource) -> void:
	pass
