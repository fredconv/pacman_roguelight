extends Node

enum Team {
	PLAYER,
	GHOST
}

signal defeated(victim: Node, killer: Node)
signal defeated_other(killer: Node, victim: Node)

@export var team: Team = Team.PLAYER
@export var contact_radius: float = 20.0

var owner_node: Node2D
var state_machine: Node

func setup(owner: Node2D, machine: Node, assigned_team: Team) -> void:
	owner_node = owner
	state_machine = machine
	team = assigned_team

func is_dead() -> bool:
	return state_machine != null and state_machine.has_method("is_state") and state_machine.is_state(&"dead")

func resolve_contact_with(other: Node) -> void:
	if other == null or owner_node == null:
		return
	if not other.has_method("is_dead") or not other.has_method("can_defeat") or not other.has_method("mark_defeated"):
		return
	if is_dead() or other.is_dead():
		return
	var other_owner_variant = other.get("owner_node")
	if not (other_owner_variant is Node2D):
		return

	var other_owner: Node2D = other_owner_variant
	if not has_physical_overlap(owner_node, other_owner):
		# Fallback minimal si une shape est absente/invalide
		if owner_node.global_position.distance_to(other_owner.global_position) > contact_radius:
			return

	var self_can_defeat: bool = can_defeat(other)
	var other_can_defeat: bool = other.can_defeat(self)

	if self_can_defeat and not other_can_defeat:
		other.mark_defeated(owner_node)
		defeated_other.emit(owner_node, other_owner)
	elif other_can_defeat and not self_can_defeat:
		mark_defeated(other_owner)

func has_physical_overlap(a: Node2D, b: Node2D) -> bool:
	var a_collision := a.get_node_or_null("CollisionShape2D")
	if a_collision == null or a_collision.shape == null:
		return false

	var shape: Shape2D = a_collision.shape
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = (a_collision as Node2D).global_transform
	query.exclude = [a.get_rid()]

	var space_state := a.get_world_2d().direct_space_state
	var hits: Array[Dictionary] = space_state.intersect_shape(query, 8)
	for hit in hits:
		var collider = hit.get("collider")
		if collider == b:
			return true
	return false

func can_defeat(other: Node) -> bool:
	if team == Team.PLAYER:
		# Player defeats ghost only when powered (e.g. super gem / power pellet)
		return state_machine != null and state_machine.has_method("is_state") and state_machine.is_state(&"powered")
	if team == Team.GHOST:
		# Ghost defeats player except when frightened/dead
		if state_machine == null or not state_machine.has_method("is_state"):
			return true
		return not state_machine.is_state(&"frightened") and not state_machine.is_state(&"dead")
	return false

func mark_defeated(killer: Node) -> void:
	if is_dead():
		return
	if state_machine and state_machine.has_method("set_state"):
		state_machine.set_state(&"dead")
	defeated.emit(owner_node, killer)
