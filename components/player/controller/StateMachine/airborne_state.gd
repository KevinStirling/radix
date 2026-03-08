extends PlayerState

@export var AIR_ACCELERATION : float = 10.0  # Same as ground for strafing to work
@export var AIR_SPEED : float = 1.5  # This is the key - much lower "wishspeed" cap in air
@export var FRICTION : float = 4.0 ## The multiplier of dropped speed when friction is acting on the player. The default value equals 4.

func _on_airborne_state_physics_processing(delta: float) -> void:
	if player.direction:
		_air_accelerate(delta, player.direction, AIR_SPEED, AIR_ACCELERATION)
 
    # Check for landing
	if player.is_on_floor():
		if player.check_fall_speed():
			player.camera_effects.add_fall_kick(3.0)

		if player.enable_bhop && Input.is_action_pressed("pm_jump"):
			player.jump()
		else:
			player.state_chart.send_event("onGrounded")

	player.current_fall_velocity = player.velocity.y


func _air_accelerate(delta: float, wishdir: Vector3, wishspeed: float, accel: float) -> void:
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
	
	# player.velocity += accelspeed * wishdir
	player.velocity.x += accelspeed * wishdir.x
	player.velocity.z += accelspeed * wishdir.z
