extends PlayerState


func _on_standing_state_physics_processing(delta: float) -> void:
	player_controller.camera.update_camera_height(delta, 1)

	# note: is_on_floor check prevents jump crouching. remove check if this is wanted
	if Input.is_action_pressed("pm_duck"):
		player_controller.state_chart.send_event("onCrouching")


func _on_standing_state_entered() -> void:
	player_controller.stand()
