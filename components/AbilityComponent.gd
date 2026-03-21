extends Node
class_name AbilityComponent

signal ability_used(ability_name: String)
signal ability_added(ability_id: StringName, level: int)
signal ability_upgraded(ability_id: StringName, level: int)

var entity: CharacterBody2D
var installed_abilities: Dictionary = {}
var installed_data: Dictionary = {}

func setup(parent_entity: CharacterBody2D) -> void:
	entity = parent_entity
	name = "AbilityComponent"

func add_or_upgrade_ability(ability_data: AbilityData) -> Node:
	if ability_data == null or ability_data.component_scene == null:
		return null

	var ability_id: StringName = ability_data.id
	if installed_abilities.has(ability_id):
		var existing_ability: Node = installed_abilities[ability_id]
		if existing_ability.has_method("upgrade"):
			existing_ability.upgrade(ability_data)
		installed_data[ability_id] = ability_data
		ability_upgraded.emit(ability_id, ability_data.level)
		return existing_ability

	var ability_instance: Node = ability_data.component_scene.instantiate()
	if ability_instance == null:
		return null

	ability_instance.name = str(ability_id).to_pascal_case() + "Ability"
	add_child(ability_instance)
	if ability_instance.has_method("setup"):
		ability_instance.setup(entity, ability_data)

	installed_abilities[ability_id] = ability_instance
	installed_data[ability_id] = ability_data
	ability_added.emit(ability_id, ability_data.level)
	return ability_instance

func has_ability(ability_id: StringName) -> bool:
	return installed_abilities.has(ability_id)

func get_ability_level(ability_id: StringName) -> int:
	if installed_data.has(ability_id):
		return int(installed_data[ability_id].level)
	return 0

func get_ability(ability_id: StringName) -> Node:
	return installed_abilities.get(ability_id)

func activate_ability(ability_id: StringName) -> bool:
	var ability: Node = installed_abilities.get(ability_id)
	if ability == null or not ability.has_method("activate"):
		return false
	var activated: bool = ability.activate()
	if activated:
		ability_used.emit(String(ability_id))
	return activated

func activate_input_action(action_name: StringName) -> bool:
	for ability_id in installed_abilities.keys():
		var ability: Node = installed_abilities[ability_id]
		if ability == null or not ability.has_method("get_input_action"):
			continue
		if ability.get_input_action() != action_name:
			continue
		if activate_ability(ability_id):
			return true
	return false

func get_installed_abilities() -> Array:
	return installed_abilities.values()