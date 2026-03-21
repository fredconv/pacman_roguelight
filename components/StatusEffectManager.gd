extends Node
class_name StatusEffectManager

var health_component: HealthComponent

func setup(target_health_component: HealthComponent) -> void:
	health_component = target_health_component

func apply_poison(damage_per_second: float, duration: float) -> void:
	if health_component == null:
		return
	var total_ticks: int = maxi(1, int(duration))
	for _i in range(total_ticks):
		await get_tree().create_timer(1.0).timeout
		if health_component != null and health_component.is_alive():
			health_component.take_damage(int(damage_per_second))

func apply_regeneration(heal_per_second: float, duration: float) -> void:
	if health_component == null:
		return
	var total_ticks: int = maxi(1, int(duration))
	for _i in range(total_ticks):
		await get_tree().create_timer(1.0).timeout
		if health_component != null and health_component.is_alive():
			health_component.heal(int(heal_per_second))
