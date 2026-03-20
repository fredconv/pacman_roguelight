extends Node

# Point d'entrée du jeu - Le SceneManager prend le relais
class_name MainGame

func _ready():
	print("🚀 MainGame démarré - Le SceneManager va prendre le relais")
	# Le SceneManager est configuré comme autoload et va gérer toutes les scènes automatiquement
