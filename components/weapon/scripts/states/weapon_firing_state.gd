extends WeaponState


func _on_firing_state_entered() -> void:
	if not weapon_controller:
		print("no weapon!")
		return

	# Fire immediately
	weapon_controller.fire_weapon()


func _on_firing_state_physics_processing(_delta: float) -> void:
	if not weapon_controller:
		return

	# Check if ammo is empty
	if weapon_controller.current_ammo <= 0:
		weapon_controller.weapon_state_chart.send_event("onEmpty")
		return

	# check fire mode
	if weapon_controller.current_weapon.is_automatic:
		if Input.is_action_pressed("weapon_primary_fire"):
			if weapon_controller.can_fire():
				weapon_controller.fire_weapon()
		else:
			# trigger released, return to idle
			weapon_controller.weapon_state_chart.send_event("onIdle")
	else:
		# semi-auto: fire once then return to idle
		weapon_controller.weapon_state_chart.send_event("onIdle")
