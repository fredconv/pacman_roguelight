extends Area2D

@export var pickup_stats: PickupStats

signal picked(target: Node)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	picked.emit(body)
	if body.has_method("apply_pickup"):
		body.apply_pickup(pickup_stats)
	queue_free()
