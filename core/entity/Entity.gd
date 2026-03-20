extends CharacterBody2D
class_name Entity

signal health_changed(current: int, maximum: int)
signal entity_died(entity: Node)

@export var stats_resource: EntityStats

@onready var movement_component: Node = $MovementComponent
@onready var stats_component: Node = $StatsComponent
@onready var health_component: Node = $HealthComponent
@onready var damage_receiver_component: Node = $DamageReceiverComponent
@onready var state_machine: Node = $StateMachine

var desired_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	if stats_component:
		stats_component.setup(stats_resource)
	if movement_component:
		movement_component.setup(self)
	if health_component:
		health_component.setup(self, stats_component)
		health_component.health_changed.connect(_on_health_changed)
		health_component.died.connect(_on_died)
	if damage_receiver_component:
		damage_receiver_component.setup(health_component)
	if state_machine:
		state_machine.setup(self)

func _physics_process(delta: float) -> void:
	if state_machine:
		state_machine.physics_step(delta)
	if movement_component and stats_component:
		movement_component.physics_step(delta, stats_component.get_base_speed())

func set_move_direction(direction: Vector2) -> void:
	desired_direction = direction
	if movement_component:
		movement_component.set_direction(direction)

func get_desired_direction() -> Vector2:
	return desired_direction

func set_state(state_name: StringName) -> void:
	if state_machine:
		state_machine.change_state(state_name)

func receive_damage(amount: int, source: Node = null) -> void:
	if damage_receiver_component and damage_receiver_component.has_method("receive_damage"):
		damage_receiver_component.receive_damage(amount, source)

func _on_health_changed(current: int, maximum: int) -> void:
	health_changed.emit(current, maximum)

func _on_died(entity_node: Node) -> void:
	entity_died.emit(entity_node)
