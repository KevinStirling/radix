extends PlayerState

@export var ACCELERATION : float = 1.0 ## The base acceleration amount that is multiplied by [code]wishspeed[/code] inside of [method _accelerate]. The default value equals 10.
@export var FRICTION : float = 4.0 ## The multiplier of dropped speed when friction is acting on the player. The default value equals 4.

func _on_grounded_state_physics_processing(delta: float) -> void:
	# _friction(delta, 1.0)
	# _accelerate(delta, player_controller.direction, player_controller.wish_dir.length(), ACCELERATION) 

	if Input.is_action_just_pressed("pm_jump") and player_controller.is_on_floor():
		player_controller.jump()
		player_controller.state_chart.send_event("onAirborne")

	if not player_controller.is_on_floor():
		player_controller.state_chart.send_event("onAirborne")

func _friction(delta: float, strenth: float) -> void:
	var control = player_controller.stop_speed if (player_controller.speed < player_controller.stop_speed) else player_controller.speed
	var drop = control * (FRICTION * strenth) * delta

	var newspeed = player_controller.speed - drop

	if newspeed < 0:
		newspeed = 0

	if player_controller.speed > 0:
		newspeed /= player_controller.speed

	player_controller.velocity.x *= newspeed
	player_controller.velocity.z *= newspeed

func _accelerate(delta: float, wishdir: Vector3, wishspeed: float, accel: float) -> void:
	# rather than doing the setting of the velocity here, maybe its better to just change the player
	# controller values here and let the player controller manage the velocity changes based on the  values
	# consider reworking the direction in player controller to also calculate wish_dir
	# accelspeed should be a player_controller var
	# then just calculate addspeed and accelspeed here, set accelspeed on player_controller
	# I may already be doing something extrememly similar, just slightly different (lerping velocity i.e.)
	var addspeed : float
	var accelspeed : float
	var currentspeed : float

	# check for direction change
	currentspeed = player_controller.velocity.dot(wishdir)

	# reduce wishspeed by the amount of veer
	addspeed = wishspeed - currentspeed

	if addspeed <= 0:
		return

	# determine amount of acceleration
	accelspeed = accel * wishspeed * delta

	# cap acceleration at addspeed
	if accelspeed > addspeed:
		accelspeed = addspeed
	
	player_controller.velocity += accelspeed * wishdir
