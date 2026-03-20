extends Area2D

# Power pellet collectible
class_name PowerPellet

signal collected

@onready var sprite: Sprite2D = Sprite2D.new()
@onready var collision: CollisionShape2D = CollisionShape2D.new()

func _ready():
	# Ajouter au groupe pour détection par distance
	add_to_group("power_pellets")

	# Set up power pellet appearance
	setup_sprite()
	setup_collision()

	# Les signaux Area2D ne sont plus nécessaires
	# body_entered.connect(_on_body_entered)

	# Animate the power pellet (pulsing effect)
	animate_pellet()

func setup_sprite():
	# Utiliser le vrai sprite de gros pellet
	var texture = load("res://Assets/Pellet/Pellet_Large.png")
	sprite.texture = texture
	sprite.scale = Vector2(1.2, 1.2)  # Légèrement plus gros
	add_child(sprite)

func setup_collision():
	# AJOUTER CollisionShape2D pour la détection
	var shape = CircleShape2D.new()
	shape.radius = 10.0  # Zone de collecte plus grande
	collision.shape = shape
	add_child(collision)

	# Configuration de l'Area2D
	collision_layer = 4  # Layer pour les collectibles
	collision_mask = 2   # Détecte seulement le joueur (layer 2)

	monitoring = true    # Peut détecter le joueur
	monitorable = true   # Visible aux autres

	# Connecter le signal de détection
	body_entered.connect(_on_body_entered)

func animate_pellet():
	# Create pulsing animation
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.5)
	tween.tween_property(sprite, "scale", Vector2(0.8, 0.8), 0.5)

func _on_body_entered(body):
	if body.name == "Player":  # Check if it's the player
		collect()

func collect():
	print("🔴 Power Pellet collecté!")
	collected.emit()
	queue_free()