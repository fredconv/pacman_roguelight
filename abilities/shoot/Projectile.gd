extends Area2D

@export var speed: float = 420.0
@export var damage: int = 8

var direction: Vector2 = Vector2.RIGHT

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.has_method("receive_damage"):
		body.receive_damage(damage, self)
	queue_free()
