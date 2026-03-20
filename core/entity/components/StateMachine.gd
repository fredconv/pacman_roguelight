extends Node

signal state_changed(from: StringName, to: StringName)

var owner_entity: Node
var states: Dictionary = {}
var current_state: Node

func setup(entity: Node) -> void:
	owner_entity = entity
	states.clear()
	for child in get_children():
		if child.has_method("enter") and child.has_method("exit") and child.has_method("update"):
			child.set("entity", owner_entity)
			states[child.name] = child
	if states.has("IdleState"):
		change_state("IdleState")

func change_state(next_name: StringName) -> void:
	if not states.has(next_name):
		return
	var from_name: StringName = &""
	if current_state != null:
		from_name = current_state.name
		current_state.exit()
	current_state = states[next_name]
	current_state.enter()
	state_changed.emit(from_name, next_name)

func physics_step(delta: float) -> void:
	if current_state != null:
		current_state.update(delta)
