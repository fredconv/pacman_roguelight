extends Area2D

# Collectible dot
class_name Dot

signal collected

@onready var sprite: Sprite2D = Sprite2D.new()
@onready var collision: CollisionShape2D = CollisionShape2D.new()

func _ready():
	# Ajouter au groupe pour détection par distance
	add_to_group("dots")

	# Set up dot appearance
	setup_sprite()
	setup_collision()

	# Les signaux Area2D ne sont plus nécessaires sans CollisionShape2D
	# body_entered.connect(_on_body_entered)

func setup_sprite():
	# Utiliser le vrai sprite de pellet
	var texture = load("res://Assets/Pellet/Pellet_Small.png")
	sprite.texture = texture
	sprite.scale = Vector2(1.0, 1.0)  # Taille normale
	add_child(sprite)

func setup_collision():
	# AJOUTER CollisionShape2D pour la détection
	var shape = CircleShape2D.new()
	shape.radius = 6.0  # Zone de collecte
	collision.shape = shape
	add_child(collision)

	# Configuration de l'Area2D
	collision_layer = 4  # Layer pour les collectibles
	collision_mask = 2   # Détecte seulement le joueur (layer 2)

	monitoring = true    # Peut détecter le joueur
	monitorable = true   # Visible aux autres

	# Connecter le signal de détection
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":  # Check if it's the player
		collect()

func collect():
	collected.emit()
	queue_free()