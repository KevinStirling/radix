extends PlayerState

func _on_grounded_state_physics_processing(delta: float) -> void:
	_friction(delta, 1.0)
	if player.direction:
		_accelerate(delta, player.direction, player.speed, player.acceleration) 

	if Input.is_action_just_pressed("pm_jump") and player.is_on_floor():
		player.jump()
		player.state_chart.send_event("onAirborne")

	if not player.is_on_floor():
		player.state_chart.send_event("onAirborne")

func _friction(delta: float, strenth: float) -> void:
	var current_speed = Vector2(player.velocity.x, player.velocity.z).length()

	# avoid division by zero when player is basically stopped
	if current_speed < 0.1:
		return

	var control = player.stop_speed if (current_speed < player.stop_speed) else current_speed 
	var drop = control * player.friction * strenth * delta

	var newspeed = current_speed - drop

	if newspeed < 0:
		newspeed = 0

	# scale factor
	newspeed /= current_speed

	player.velocity.x *= newspeed
	player.velocity.z *= newspeed

func _accelerate(delta: float, wishdir: Vector3, wishspeed: float, accel: float) -> void:
	var addspeed : float
	var accelspeed : float
	var currentspeed : float

	# check for direction change
	currentspeed = player.velocity.dot(wishdir)

	# reduce wishspeed by the amount of veer
	addspeed = wishspeed - currentspeed

	if addspeed <= 0:
		return

	# determine amount of acceleration
	accelspeed = accel * wishspeed * delta

	# cap acceleration at addspeed
	if accelspeed > addspeed:
		accelspeed = addspeed
	
	player.velocity += accelspeed * wishdir
