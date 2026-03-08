extends PlayerState

@export var ACCELERATION : float = 1.0 ## The base acceleration amount that is multiplied by [code]wishspeed[/code] inside of [method _accelerate]. The default value equals 10.
@export var FRICTION : float = 4.0 ## The multiplier of dropped speed when friction is acting on the player. The default value equals 4.

func _on_grounded_state_physics_processing(delta: float) -> void:
	_friction(delta, 1.0)
	if player_controller.direction:
		_accelerate(delta, player_controller.direction, player_controller.speed, player_controller.acceleration) 

	if Input.is_action_just_pressed("pm_jump") and player_controller.is_on_floor():
		player_controller.jump()
		player_controller.state_chart.send_event("onAirborne")

	if not player_controller.is_on_floor():
		player_controller.state_chart.send_event("onAirborne")

func _friction(delta: float, strenth: float) -> void:
	var current_speed = Vector2(player_controller.velocity.x, player_controller.velocity.z).length()

	# avoid division by zero when player is basically stopped
	if current_speed < 0.1:
		return

	var control = player_controller.stop_speed if (current_speed < player_controller.stop_speed) else current_speed 
	var drop = control * FRICTION * strenth * delta

	var newspeed = current_speed - drop

	if newspeed < 0:
		newspeed = 0

	# scale factor
	newspeed /= current_speed

	player_controller.velocity.x *= newspeed
	player_controller.velocity.z *= newspeed

func _accelerate(delta: float, wishdir: Vector3, wishspeed: float, accel: float) -> void:
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
