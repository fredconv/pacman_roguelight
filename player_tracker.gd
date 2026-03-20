extends Node

# Debug système pour tracker les mouvements du joueur
# Attach ce script à un Node dans la scène principale

var player_positions: Array[Vector2] = []
var max_history: int = 100
var last_logged_time: float = 0.0

func _ready():
	print("🔍 SYSTÈME DE TRACKING AVANCÉ activé")
	print("Contrôles de debug:")
	print("  [P] - Afficher historique des positions")
	print("  [R] - Reset position joueur au centre")
	print("  [L] - Toggle logging continu")

var continuous_logging: bool = false

func _physics_process(_delta):
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	# Enregistrer position dans l'historique
	player_positions.append(player.global_position)
	if player_positions.size() > max_history:
		player_positions.pop_front()

	# Logging continu si activé
	if continuous_logging and Time.get_time_dict_from_system()["second"] != last_logged_time:
		last_logged_time = Time.get_time_dict_from_system()["second"]
		print("Position joueur: ", player.global_position, " | Vitesse: ", player.velocity)

func _input(event):
	if event.is_action_pressed("ui_text_completion_query"):  # P key
		show_position_history()
	elif event.is_action_pressed("ui_text_completion_replace"):  # R key
		reset_player_position()
	elif event.is_action_pressed("ui_text_clear_carets_and_selection"):  # L key
		toggle_continuous_logging()

func show_position_history():
	print("\n📊 HISTORIQUE DES POSITIONS (dernières ", min(10, player_positions.size()), " positions):")
	var start_idx = max(0, player_positions.size() - 10)
	for i in range(start_idx, player_positions.size()):
		var pos = player_positions[i]
		var in_bounds = is_in_bounds(pos)
		var status = "✅ OK" if in_bounds else "❌ HORS LIMITES"
		print("  [", i, "] ", pos, " ", status)

func reset_player_position():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		print("🔄 RESET position joueur")
		player.global_position = Vector2(320, 320)
		player.velocity = Vector2.ZERO
		player.current_direction = Vector2.ZERO
		if player.has_method("align_to_grid"):
			player.align_to_grid()

func toggle_continuous_logging():
	continuous_logging = !continuous_logging
	print("📝 Logging continu: ", "ACTIVÉ" if continuous_logging else "DÉSACTIVÉ")

func is_in_bounds(pos: Vector2) -> bool:
	return pos.x >= -50 and pos.x <= 700 and pos.y >= -50 and pos.y <= 650

# Détection automatique de téléportation
func _on_position_changed(old_pos: Vector2, new_pos: Vector2):
	var distance = old_pos.distance_to(new_pos)
	if distance > 100:  # Téléportation détectée
		print("🚨 TÉLÉPORTATION DÉTECTÉE!")
		print("   De: ", old_pos, " vers: ", new_pos)
		print("   Distance: ", distance)