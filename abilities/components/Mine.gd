extends Area2D

signal ghost_triggered(ghost: Node)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body != null and body.is_in_group("ghosts"):
		ghost_triggered.emit(body)
		queue_free()
