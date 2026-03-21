extends Node

signal state_changed(previous: StringName, current: StringName)

@export var current_state: StringName = &"normal"

func set_state(next_state: StringName) -> void:
	if next_state == current_state:
		return
	var previous := current_state
	current_state = next_state
	state_changed.emit(previous, current_state)

func is_state(query_state: StringName) -> bool:
	return current_state == query_state
