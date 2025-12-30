class_name CameraEffects extends Camera3D

@export_category("References")
@export var player : PlayerController

@export_category("Effects")
## player camera tilt influenced by velocity
@export var enable_tilt : bool = true
## player camera tilt and offset influenced by fall height
@export var enable_fall_kick : bool = true
## player camera tilt influenced by direction of damage taken
@export var enable_damage_kick : bool = true
## player camera effects influenced by firing a weapon
@export var enable_weapon_kick : bool = true
## screen shake effects influence by world events
@export var enable_screen_shake : bool = true
## head bob effect while player movement is not idle
@export var enable_head_bob : bool = true

@export_category("Kick & Recoil Settings")
@export_group("Run Tilt")
@export var run_pitch : float = 0.1
@export var run_roll : float = 0.25
@export var max_pitch : float = 1.0
@export var max_roll : float = 2.5
@export var tilt_smoothing : float = 0.1
@export_group("Camera Kick")
@export_subgroup("Fall Kick")
@export var fall_time : float = 0.3
@export_subgroup("Damage Kick")
@export var damage_time : float = 0.3
@export_subgroup("Weapon Kick")
@export var weapon_decay : float = 0.5
@export var weapon_kick_pitch_limit : float = 0.2
@export_subgroup("Headbob")
@export_range(0.0, 0.1, 0.001) var bob_pitch : float = 0.05
@export_range(0.0, 0.1, 0.001) var bob_roll : float = 0.025
@export_range(0.0, 0.04, 0.001) var bob_up : float = 0.015
@export_range(3.0, 8.0, 0.1) var bob_frequency : float = 6.0

var _fall_value : float = 0.0
var _fall_timer : float = 0.0

var _damage_pitch : float = 0.0
var _damage_roll : float = 0.0
var _damage_timer : float = 0.0

var _weapon_kick_angles : Vector3 = Vector3.ZERO

var _screen_shake_tween : Tween

var _step_timer : float = 0.0

const MIN_SCREEN_SHAKE : float = 0.05
const MAX_SCREEN_SHAKE : float = 0.5

func _process(delta: float) -> void:
	calculate_view_offset(delta)
	if Input.is_action_just_pressed("test"):
		# add_screen_shake(0.2, 1.0)
		add_weapon_kick(6.0, 2.0, 1.0)

## calculates how to offset the view of the camera given the player velocity
##
## Each of these effects will be used to update the rotation when enabled:
##
## enable_tilt: uses the dot product of the forward direction of the camera 
## (global_transform.basis.z) and right (global_transform.basis.x) to determine
## how close the movement vector is to the direction the camera is facing.
## the dot product is then used to detrmine the tilt amount
##
## enable_fall_kick: uses the fall_time and _fall_value (effect strength modifier)
## to determine the angle and position offset of the camera. Used to dynamically
## effect the camera based on varying fall heights
##
## enable_damage_kick: uses _damage_pitch and _damage_roll 
## (calculated by add_damage_kick) to add rotation based on the direction of 
## incoming damage
##
## enable_weapon_kick: uses _weapon_kick_angles set by add_weapon_kick to rotate
## the camera, while limiting pitch by weapon_kick_pitch_limit and returning to 
## center with weapon_decay
func calculate_view_offset(delta):
	if not player:
		return

	_fall_timer -= delta
	_damage_timer -= delta

	var velocity = player.velocity

	var angles = Vector3.ZERO
	var offset = Vector3.ZERO

	# head bob step timer and sin value
	var speed = Vector2(velocity.x, velocity.z).length()
	if speed > 0.1 and player.is_on_floor():
		_step_timer += delta * (speed / bob_frequency)
		_step_timer = fmod(_step_timer, 1.0)
	else: 
		_step_timer = 0.0
	var bob_sin = absf(sin(_step_timer * 2.0 * PI) * 0.5)

	if enable_tilt:
		var forward = global_transform.basis.z
		var right = global_transform.basis.x

		var forward_dot = velocity.dot(forward)
		var forward_tilt = clampf(forward_dot * deg_to_rad(run_pitch), deg_to_rad(-max_pitch), deg_to_rad(max_pitch))
		angles.x += forward_tilt

		var right_dot = velocity.dot(right)
		var side_tilt = clampf(right_dot * deg_to_rad(run_roll), deg_to_rad(-max_roll), deg_to_rad(max_roll))
		angles.z -= side_tilt

	
	if enable_fall_kick:
		var fall_ratio = max(0.0, _fall_timer / fall_time)
		var fall_kick_amount = fall_ratio * _fall_value
		angles.x -= fall_kick_amount
		offset.y -= fall_kick_amount

	if enable_damage_kick:
		var damage_ratio = max(0.0, _damage_timer / damage_time)
		angles.x += damage_ratio * _damage_pitch
		angles.z += damage_ratio * _damage_roll
	
	if enable_weapon_kick:
		_weapon_kick_angles = _weapon_kick_angles.move_toward(Vector3.ZERO, weapon_decay * delta)
		_weapon_kick_angles.x = clampf(_weapon_kick_angles.x, 0.0, weapon_kick_pitch_limit)
		angles += _weapon_kick_angles

	if enable_head_bob:
		var pitch_delta = bob_sin * deg_to_rad(bob_pitch) * speed
		angles.x -= pitch_delta

		var roll_delta = bob_sin * deg_to_rad(bob_roll) * speed
		angles.z -= roll_delta

		var bob_height = bob_sin * speed * bob_up
		offset.y += bob_height

	position = offset
	# todo: may want to experiment with different smoothing methods like move_toward or ease
	rotation = lerp(rotation, angles, delta / tilt_smoothing)

## add a fall kick to the player camera. higher fall_strength will increase
## the camera tilt.
func add_fall_kick(fall_strength: float):
	_fall_value = deg_to_rad(fall_strength)
	_fall_timer = fall_time

## add a damage kick to the player camera when damage is recieved
## pitch and roll will effect the camera rotation amount
## source will effect the direction of the camera rotation
func add_damage_kick(pitch: float, roll: float, source: Vector3):
	var forward = global_transform.basis.z
	var right = global_transform.basis.x
	var direction = global_position.direction_to(source)
	var forward_dot = direction.dot(forward)
	var right_dot = direction.dot(right)
	_damage_pitch = deg_to_rad(pitch) * forward_dot
	_damage_roll = deg_to_rad(roll) * right_dot
	_damage_timer = damage_time

## add weapon kick when firing a weapon
## generally recommended to keep the yaw and roll values low
## pitch will be auto limitted by the weapon_kick_pitch_limit
func add_weapon_kick(pitch: float, yaw: float, roll: float):
	_weapon_kick_angles.x += deg_to_rad(pitch)
	_weapon_kick_angles.y += deg_to_rad(randf_range(-yaw, yaw))
	_weapon_kick_angles.z += deg_to_rad(randf_range(-roll, roll))

func add_screen_shake(amount: float, seconds: float) -> void:
	if _screen_shake_tween:
		_screen_shake_tween.kill()
	
	_screen_shake_tween = create_tween()
	_screen_shake_tween.tween_method(update_screen_shake.bind(amount), 0.0, 1.0, seconds).set_ease(Tween.EASE_OUT)

func update_screen_shake(alpha: float, amount: float) -> void:
	amount = remap(amount, 0.0, 1.0, MIN_SCREEN_SHAKE, MAX_SCREEN_SHAKE)
	var current_shake_amount = amount * (1.0 - alpha)
	h_offset = randf_range(-current_shake_amount, current_shake_amount)	
	v_offset = randf_range(-current_shake_amount, current_shake_amount)
