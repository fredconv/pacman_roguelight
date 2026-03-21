extends Control

class_name UpgradeScreen

signal ability_selected(ability_data: AbilityData)
signal menu_requested()

var title_label: Label
var subtitle_label: Label
var cards_container: HBoxContainer
var background: ColorRect
var root_center: CenterContainer
var main_panel: PanelContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	_setup_ui()
	_sync_to_viewport()

func show_choices(choices: Array[AbilityData]) -> void:
	_sync_to_viewport()
	_clear_cards()
	for ability_data in choices:
		_create_ability_card(ability_data)
	visible = true
	modulate = Color(1.0, 1.0, 1.0, 1.0)

func hide_screen() -> void:
	visible = false
	_clear_cards()

func _setup_ui() -> void:
	background = ColorRect.new()
	background.color = Color(0.03, 0.03, 0.05, 0.88)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	root_center = CenterContainer.new()
	root_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root_center)

	main_panel = PanelContainer.new()
	main_panel.custom_minimum_size = Vector2(860, 340)
	root_center.add_child(main_panel)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.08, 0.11, 0.98)
	panel_style.border_color = Color(0.97, 0.73, 0.16)
	panel_style.corner_radius_top_left = 16
	panel_style.corner_radius_top_right = 16
	panel_style.corner_radius_bottom_left = 16
	panel_style.corner_radius_bottom_right = 16
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	main_panel.add_theme_stylebox_override("panel", panel_style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	main_panel.add_child(margin)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 18)
	margin.add_child(layout)

	title_label = Label.new()
	title_label.text = "Choisis une capacite"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 28)
	layout.add_child(title_label)

	subtitle_label = Label.new()
	subtitle_label.text = "Trois choix aleatoires. La capacite choisie est conservee apres le respawn."
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_size_override("font_size", 14)
	subtitle_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.87))
	layout.add_child(subtitle_label)

	cards_container = HBoxContainer.new()
	cards_container.alignment = BoxContainer.ALIGNMENT_CENTER
	cards_container.add_theme_constant_override("separation", 18)
	layout.add_child(cards_container)

	var footer := HBoxContainer.new()
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	footer.add_theme_constant_override("separation", 14)
	layout.add_child(footer)

	var footer_label := Label.new()
	footer_label.text = "Esc : retour menu"
	footer_label.add_theme_font_size_override("font_size", 13)
	footer_label.add_theme_color_override("font_color", Color(0.72, 0.72, 0.78))
	footer.add_child(footer_label)

func _create_ability_card(ability_data: AbilityData) -> void:
	var card := VBoxContainer.new()
	card.custom_minimum_size = Vector2(230, 170)
	card.add_theme_constant_override("separation", 10)
	card.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	var button := Button.new()
	button.custom_minimum_size = Vector2(230, 120)
	button.text = "%s\nNiveau %d" % [ability_data.name, ability_data.level]
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(_on_ability_button_pressed.bind(ability_data))
	card.add_child(button)

	var button_style := StyleBoxFlat.new()
	button_style.bg_color = Color(0.12, 0.14, 0.18, 1.0)
	button_style.border_color = Color(0.27, 0.81, 0.82)
	button_style.corner_radius_top_left = 14
	button_style.corner_radius_top_right = 14
	button_style.corner_radius_bottom_left = 14
	button_style.corner_radius_bottom_right = 14
	button_style.border_width_left = 2
	button_style.border_width_right = 2
	button_style.border_width_top = 2
	button_style.border_width_bottom = 2
	button.add_theme_stylebox_override("normal", button_style)
	button.add_theme_stylebox_override("hover", button_style)
	button.add_theme_stylebox_override("pressed", button_style)
	button.add_theme_font_size_override("font_size", 18)

	var description := Label.new()
	description.text = ability_data.description
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.custom_minimum_size = Vector2(230, 40)
	description.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	description.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	description.add_theme_font_size_override("font_size", 13)
	description.add_theme_color_override("font_color", Color(0.9, 0.92, 0.95))
	card.add_child(description)

	cards_container.add_child(card)

func _clear_cards() -> void:
	for child in cards_container.get_children():
		child.free()

func _sync_to_viewport() -> void:
	var viewport_rect := get_viewport_rect()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if background:
		background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if root_center:
		root_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if main_panel:
		var panel_width := clampf(viewport_rect.size.x - 64.0, 540.0, 900.0)
		var panel_height := clampf(viewport_rect.size.y - 96.0, 300.0, 420.0)
		main_panel.custom_minimum_size = Vector2(panel_width, panel_height)

func _on_ability_button_pressed(ability_data: AbilityData) -> void:
	ability_selected.emit(ability_data)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		menu_requested.emit()
		get_viewport().set_input_as_handled()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_sync_to_viewport()