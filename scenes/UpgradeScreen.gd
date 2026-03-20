extends Control

# Upgrade selection screen for roguelite progression
class_name UpgradeScreen

signal upgrade_selected(upgrade_type: String, value: float)

# Available upgrades
var upgrade_options = {
	"speed": {
		"name": "Speed Boost",
		"description": "Increase movement speed by 25%",
		"value": 50.0,
		"icon": "⚡"
	},
	"lives": {
		"name": "Extra Life",
		"description": "Gain an additional life",
		"value": 1.0,
		"icon": "❤️"
	},
	"dash": {
		"name": "Dash Cooldown",
		"description": "Reduce dash cooldown by 0.5s",
		"value": -0.5,
		"icon": "🏃"
	},
	"shield": {
		"name": "Shield Charge",
		"description": "Gain 2 shield charges",
		"value": 2.0,
		"icon": "🛡️"
	},
	"ghost_slow": {
		"name": "Ghost Slowdown",
		"description": "Ghosts move 15% slower",
		"value": 0.15,
		"icon": "🐌"
	},
	"score_multiplier": {
		"name": "Score Multiplier",
		"description": "Increase score gain by 50%",
		"value": 0.5,
		"icon": "💰"
	}
}

# Node references - will be created dynamically
var title_label: Label
var upgrade_container: HBoxContainer
var background: ColorRect

var selected_upgrades: Array[String] = []

func _ready():
	# Set up the upgrade screen appearance
	setup_ui()
	hide()  # Initially hidden

func setup_ui():
	# Create background
	if not background:
		background = ColorRect.new()
		background.color = Color(0, 0, 0, 0.8)
		background.anchors_preset = Control.PRESET_FULL_RECT
		add_child(background)

	# Create main container
	var main_vbox = VBoxContainer.new()
	main_vbox.anchors_preset = Control.PRESET_CENTER
	main_vbox.position = Vector2(-200, -150)
	main_vbox.size = Vector2(400, 300)
	background.add_child(main_vbox)

	# Title
	var title = Label.new()
	title.text = "Choose Your Upgrade"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	main_vbox.add_child(title)

	# Spacing
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	main_vbox.add_child(spacer)

	# Upgrade container
	var upgrade_hbox = HBoxContainer.new()
	upgrade_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(upgrade_hbox)

	upgrade_container = upgrade_hbox

func show_upgrade_selection():
	# Generate 3 random upgrade options
	selected_upgrades.clear()
	var available_keys = upgrade_options.keys()
	available_keys.shuffle()

	# Clear previous buttons
	for child in upgrade_container.get_children():
		child.queue_free()

	# Create upgrade buttons
	for i in range(min(3, available_keys.size())):
		var upgrade_key = available_keys[i]
		selected_upgrades.append(upgrade_key)
		create_upgrade_button(upgrade_key, upgrade_options[upgrade_key])

	show()

func create_upgrade_button(upgrade_key: String, upgrade_data: Dictionary):
	var button_container = VBoxContainer.new()
	button_container.custom_minimum_size = Vector2(120, 100)

	# Main button
	var button = Button.new()
	button.custom_minimum_size = Vector2(120, 80)
	button.text = upgrade_data.icon + "\n" + upgrade_data.name
	button.pressed.connect(_on_upgrade_selected.bind(upgrade_key))

	# Description label
	var desc_label = Label.new()
	desc_label.text = upgrade_data.description
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.custom_minimum_size = Vector2(120, 40)
	desc_label.add_theme_font_size_override("font_size", 10)

	button_container.add_child(button)
	button_container.add_child(desc_label)

	# Add spacing between buttons
	if upgrade_container.get_child_count() > 0:
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(20, 0)
		upgrade_container.add_child(spacer)

	upgrade_container.add_child(button_container)

func _on_upgrade_selected(upgrade_key: String):
	var upgrade_data = upgrade_options[upgrade_key]
	upgrade_selected.emit(upgrade_key, upgrade_data.value)
	hide()

func _input(event):
	if visible and event is InputEventKey and event.pressed:
		# Allow number keys 1-3 to select upgrades
		if event.keycode >= KEY_1 and event.keycode <= KEY_3:
			var index = event.keycode - KEY_1
			if index < selected_upgrades.size():
				_on_upgrade_selected(selected_upgrades[index])