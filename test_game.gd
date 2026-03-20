extends Node

# Script de test pour vérifier le comportement des ghosts

func _ready():
	print("=== STRICT TURN SYSTEM ACTIVE ===")
	print("Contrôles:")
	print("  [ESPACE] - Status complet")
	print("  [TAB] - Toggle assistance virages")
	print("  [SHIFT+TAB] - Changer précision (2px/4px/6px)")
	print("  [INSERT] - Toggle alignement général")
	print("  [DELETE] - Reset mouvement")
	print("  [BACKSPACE] - Forcer alignement intersection")
	print("  [ECHAP] - Téléport centre")
	print("==================================")

func _input(event):
	if event.is_action_pressed("ui_accept"):  # Space or Enter
		print("\n=== PLAYER TRACKING STATUS ===")
		var player = get_tree().get_first_node_in_group("player")
		var ghosts = get_tree().get_nodes_in_group("ghosts")

		if player:
			var player_grid_x = player.global_position.x / float(GameConstants.CELL_SIZE)
			var player_grid_y = player.global_position.y / float(GameConstants.CELL_SIZE)
			print("Player position: ", player.global_position)
			print("Player velocity: ", player.velocity)
			print("Player current_direction: ", player.current_direction)
			print("Player next_direction: ", player.next_direction)
			print("Player grid alignment: (", player_grid_x, ", ", player_grid_y, ")")
			print("Player centered: ", is_centered_on_grid(player.global_position))
			print("Player in bounds: ", is_in_play_area(player.global_position))
			print("Turn assistance: ", "ON" if player.turn_assistance_enabled else "OFF")
			print("Alignment: ", "ON" if not player.disable_alignment else "OFF")
			print("Turn precision: ", player.turn_buffer_distance, "px")
			print("Intersection distance: ", player.intersection_snap_distance, "px")

			# Distance au centre de grille
			var grid_center_x = round(player.global_position.x / float(GameConstants.CELL_SIZE)) * GameConstants.CELL_SIZE + GameConstants.HALF_CELL
			var grid_center_y = round(player.global_position.y / float(GameConstants.CELL_SIZE)) * GameConstants.CELL_SIZE + GameConstants.HALF_CELL
			var distance_to_center = player.global_position.distance_to(Vector2(grid_center_x, grid_center_y))
			print("Distance au centre de grille: ", distance_to_center)
			print("Near intersection: ", player.is_near_intersection())

			# Test de mouvement dans toutes les directions
			print("--- Tests de mouvement ---")
			print("Peut aller UP: ", player.can_move_in_direction(Vector2.UP))
			print("Peut aller DOWN: ", player.can_move_in_direction(Vector2.DOWN))
			print("Peut aller LEFT: ", player.can_move_in_direction(Vector2.LEFT))
			print("Peut aller RIGHT: ", player.can_move_in_direction(Vector2.RIGHT))

		for i in range(min(ghosts.size(), 2)):  # Show first 2 ghosts
			var ghost = ghosts[i]
			print("Ghost ", i, " position: ", ghost.global_position)
			print("Ghost ", i, " in bounds: ", is_in_play_area(ghost.global_position))
		print("================================")

	# Test de téléportation d'urgence avec T
	if event.is_action_pressed("ui_cancel"):  # Escape
		var player = get_tree().get_first_node_in_group("player")
		if player:
			print("🆘 TÉLÉPORTATION D'URGENCE du joueur au centre!")
			player.global_position = Vector2(320, 320)  # Centre approximatif
			player.align_to_grid()

	# Test spécial - forcer alignement parfait
	if event.is_action_pressed("ui_text_backspace"):  # Backspace
		var player = get_tree().get_first_node_in_group("player")
		if player:
			print("🧪 TEST - Forcer alignement parfait sur grille")
			player.force_perfect_grid_alignment()

	# Test - reset direction et vitesse
	if event.is_action_pressed("ui_text_delete"):  # Delete
		var player = get_tree().get_first_node_in_group("player")
		if player:
			print("🛑 RESET mouvement joueur")
			player.velocity = Vector2.ZERO
			player.current_direction = Vector2.ZERO
			player.next_direction = Vector2.ZERO

	# Test - vérifier spawns des ghosts
	if event.is_action_pressed("ui_text_caret_word_left"):  # Ctrl+Left
		print("\n👻 VÉRIFICATION SPAWNS GHOSTS:")
		var ghosts = get_tree().get_nodes_in_group("ghosts")
		for i in range(ghosts.size()):
			var ghost = ghosts[i]
			print("Ghost ", i, ":")
			print("  Position: ", ghost.global_position)
			print("  Home: ", ghost.home_position)

			# Test si le ghost peut bouger (pas dans un mur)
			var can_move_up = ghost.can_move_in_direction(Vector2.UP)
			var can_move_down = ghost.can_move_in_direction(Vector2.DOWN)
			var can_move_left = ghost.can_move_in_direction(Vector2.LEFT)
			var can_move_right = ghost.can_move_in_direction(Vector2.RIGHT)

			var can_move_any = can_move_up or can_move_down or can_move_left or can_move_right
			print("  Peut bouger: ", "OUI" if can_move_any else "NON (DANS MUR!)")
			if not can_move_any:
				print("  ❌ Ghost coincé dans un mur!")

	# Toggle alignement ON/OFF
	if event.is_action_pressed("ui_text_toggle_insert_mode"):  # Insert
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.disable_alignment = !player.disable_alignment
			print("🔧 Alignement ", "DÉSACTIVÉ" if player.disable_alignment else "ACTIVÉ")

	# Toggle assistance aux virages
	if event.is_action_pressed("ui_text_indent"):  # Tab
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.turn_assistance_enabled = !player.turn_assistance_enabled
			print("🎯 Assistance virages ", "ACTIVÉE" if player.turn_assistance_enabled else "DÉSACTIVÉE")

	# Ajuster précision des virages
	if event.is_action_pressed("ui_text_dedent"):  # Shift+Tab
		var player = get_tree().get_first_node_in_group("player")
		if player:
			if player.turn_buffer_distance == 8.0:
				player.turn_buffer_distance = 4.0  # Strict
				print("🎯 Précision virages: STRICTE (4px)")
			elif player.turn_buffer_distance == 4.0:
				player.turn_buffer_distance = 12.0  # Très permissif
				print("🎯 Précision virages: TRÈS PERMISSIVE (12px)")
			else:
				player.turn_buffer_distance = 8.0  # Normal
				print("🎯 Précision virages: NORMALE (8px)")

func is_centered_on_grid(pos: Vector2) -> bool:
	var grid_center_x = round(pos.x / float(GameConstants.CELL_SIZE)) * GameConstants.CELL_SIZE + GameConstants.HALF_CELL
	var grid_center_y = round(pos.y / float(GameConstants.CELL_SIZE)) * GameConstants.CELL_SIZE + GameConstants.HALF_CELL
	var center_pos = Vector2(grid_center_x, grid_center_y)

	return pos.distance_to(center_pos) < 2.0  # Within 2 pixels of center

func is_in_play_area(pos: Vector2) -> bool:
	var play_area_min = Vector2(-50, -50)
	var play_area_max = Vector2(700, 650)

	return pos.x >= play_area_min.x and pos.x <= play_area_max.x and pos.y >= play_area_min.y and pos.y <= play_area_max.y