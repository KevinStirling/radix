extends PlayerState


func _on_sprinting_state_physics_processing(_delta: float) -> void:
	if not Input.is_action_pressed("pm_sprint") || Input.is_action_pressed("pm_duck"):
		player.state_chart.send_event("onWalking")


func _on_sprinting_state_entered() -> void:
	player.sprint()
