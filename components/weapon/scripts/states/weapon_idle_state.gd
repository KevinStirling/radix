extends WeaponState


func _on_idle_state_processing(_delta: float) -> void:
	if not weapon_controller:
		return

	# Check for fire input
	if Input.is_action_just_pressed("weapon_primary_fire") and weapon_controller.can_fire():
		weapon_controller.weapon_state_chart.send_event("onFiring")

	# Check if ammo is empty
	if not weapon_controller.has_ammo():
		weapon_controller.weapon_state_chart.send_event("onEmpty")
