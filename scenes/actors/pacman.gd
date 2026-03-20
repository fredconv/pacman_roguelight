extends "res://components/Player.gd"

# Backward-compatibility wrapper.
# Keep this script so old references to `pacman.gd` still run the unified Player logic.

func _ready() -> void:
	push_warning("Deprecated: use res://scenes/actors/Player.tscn instead of pacman legacy scene.")
	super._ready()
