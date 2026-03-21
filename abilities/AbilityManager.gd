extends Node

signal choices_drawn(choices: Array)
signal ability_selected(ability_id: StringName, level: int)
signal pool_changed(pool_size: int)

const INITIAL_ABILITY_IDS: Array[StringName] = [&"extra_life", &"dash", &"speed_boost"]

var available_pool: Array[String] = []
var current_choices: Array[AbilityData] = []
var owned_levels: Dictionary = {}
var run_initialized: bool = false

func _ready() -> void:
	reset_run()

func reset_run() -> void:
	available_pool.clear()
	current_choices.clear()
	owned_levels.clear()
	for ability_id in INITIAL_ABILITY_IDS:
		available_pool.append(_get_ability_resource_path(ability_id, 1))
	run_initialized = true
	pool_changed.emit(available_pool.size())

func draw_choices(count: int = 3) -> Array[AbilityData]:
	current_choices.clear()
	var draw_pool: Array[String] = available_pool.duplicate()
	draw_pool.shuffle()
	for index in range(min(count, draw_pool.size())):
		var resource_path := draw_pool[index]
		var ability_data: AbilityData = load(resource_path)
		if ability_data:
			current_choices.append(ability_data)
	choices_drawn.emit(current_choices)
	return current_choices

func apply_choice(target: Node, chosen_ability: AbilityData) -> bool:
	if target == null or chosen_ability == null:
		return false
	if not target.has_method("get_ability_component"):
		return false

	var ability_component: Node = target.get_ability_component()
	if ability_component == null or not ability_component.has_method("add_or_upgrade_ability"):
		return false

	ability_component.add_or_upgrade_ability(chosen_ability)
	owned_levels[chosen_ability.id] = chosen_ability.level
	_update_pool_after_choice(chosen_ability)
	ability_selected.emit(chosen_ability.id, chosen_ability.level)
	return true

func get_current_choices() -> Array[AbilityData]:
	return current_choices.duplicate()

func get_owned_level(ability_id: StringName) -> int:
	return int(owned_levels.get(ability_id, 0))

func is_run_initialized() -> bool:
	return run_initialized

func _update_pool_after_choice(chosen_ability: AbilityData) -> void:
	var chosen_path := _get_ability_resource_path(chosen_ability.id, chosen_ability.level)
	available_pool.erase(chosen_path)
	if chosen_ability.level < chosen_ability.max_level:
		available_pool.append(_get_ability_resource_path(chosen_ability.id, chosen_ability.level + 1))
	pool_changed.emit(available_pool.size())

func _get_ability_resource_path(ability_id: StringName, level: int) -> String:
	return "res://abilities/ability_list/%s/%s_level_%d.tres" % [String(ability_id), String(ability_id), level]
