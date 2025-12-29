extends PlayerState


func _on_airborne_state_physics_processing(_delta: float) -> void:
	if player_controller.is_on_floor():
		if player_controller.check_fall_speed():
			player_controller.camera_effects.add_fall_kick(3.0)
		player_controller.state_chart.send_event("onGrounded")

	player_controller.current_fall_velocity = player_controller.velocity.y
