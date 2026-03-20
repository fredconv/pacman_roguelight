extends Control

# Game HUD controller
class_name HUD

@onready var score_label: Label = $ScoreLabel
@onready var lives_label: Label = $LivesLabel
@onready var level_label: Label = $LevelLabel

func _ready():
	# Initialize HUD
	update_display(0, 3, 1)

func update_display(score: int, lives: int, level: int):
	if score_label:
		score_label.text = "Score: " + str(score)

	if lives_label:
		lives_label.text = "Lives: " + str(lives)

	if level_label:
		level_label.text = "Level: " + str(level)

func show_upgrade_info(_upgrades: Dictionary):
	# Could add upgrade display here
	pass