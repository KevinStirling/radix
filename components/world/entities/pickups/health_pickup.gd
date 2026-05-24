class_name HealthPickup
extends BasePickup

@export var heal_amount: float = 25.0


# override in subclass
func can_pickup(player: PlayerController) -> bool:
	var health_component = player.get_node_or_null("HealthComponent")

	if health_component && health_component.current_health < health_component.max_health:
		return true
	return false


func apply_pickup(player: PlayerController) -> void:
	var health_component = player.get_node_or_null("HealthComponent")
	health_component.heal(heal_amount)
