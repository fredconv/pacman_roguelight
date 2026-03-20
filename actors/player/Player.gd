extends Entity

signal score_changed(new_score: int)
signal lives_changed(new_lives: int)

@export var score: int = 0
@export var lives: int = 3

@onready var dash_component: Node = $DashComponent
@onready var shoot_component: Node = $ShootComponent

func _ready() -> void:
	if stats_resource == null:
		stats_resource = preload("res://resources/stats/PlayerStats.tres")
	super._ready()
	if dash_component and dash_component.has_method("setup"):
		dash_component.setup(self)
	if shoot_component and shoot_component.has_method("setup"):
		shoot_component.setup(self)
	add_to_group("player")
	score_changed.emit(score)
	lives_changed.emit(lives)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_up"):
		set_move_direction(Vector2.UP)
		set_state("MoveState")
	elif event.is_action_pressed("move_down"):
		set_move_direction(Vector2.DOWN)
		set_state("MoveState")
	elif event.is_action_pressed("move_left"):
		set_move_direction(Vector2.LEFT)
		set_state("MoveState")
	elif event.is_action_pressed("move_right"):
		set_move_direction(Vector2.RIGHT)
		set_state("MoveState")
	if event.is_action_pressed("ability_blink") and dash_component and dash_component.has_method("try_dash"):
		dash_component.try_dash(get_desired_direction())
	if event.is_action_pressed("ui_accept") and shoot_component and shoot_component.has_method("try_shoot"):
		shoot_component.try_shoot(get_desired_direction())

func add_score(value: int) -> void:
	score += value
	score_changed.emit(score)

func lose_life() -> void:
	lives -= 1
	lives_changed.emit(lives)
	if lives <= 0:
		receive_damage(999999)

func apply_pickup(pickup_stats: Resource) -> void:
	if pickup_stats == null:
		return
	if pickup_stats.has_method("get"):
		if pickup_stats.get("speed_bonus") != null and stats_component:
			stats_component.stats.base_speed += float(pickup_stats.get("speed_bonus"))
