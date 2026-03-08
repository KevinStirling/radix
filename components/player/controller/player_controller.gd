class_name PlayerController extends CharacterBody3D

# todo: make this debug value control the enabled flag on state chart debugger w/ get&set
@export var debug : bool = false
@export_category("Movement Settings")
@export_group("Easing")
@export var acceleration : float = 1.0
@export var deceleration : float = 1.0
@export_group("Speed")
@export var default_speed: float = 5.0
@export var sprint_speed : float = 3.0
@export var crouch_speed : float = -3.0
@export var stop_speed : float = 10.0
@export_category("Jump Settings")
@export var jump_velocity : float = 5.0
@export var fall_velocity_threshold : float = -5.0
@export var fall_gravity_multiplier : float = 1.5
@export_category("BHop")
@export var enable_bhop : bool = true
@export var soft_cap_speed : float = 10.0
@export var soft_cap_factor : float = 0.5
@export_category("References")
@export var state_chart : StateChart
@export var camera : CameraController
@export var camera_effects : CameraEffects
@export var standing_collision : CollisionShape3D
@export var crouching_collision : CollisionShape3D
@export var crouch_check : ShapeCast3D
@export var interaction_raycast : RayCast3D
@export var step_handler : StepHandlerComponent

var _input_dir : Vector2 = Vector2.ZERO
var _movement_velocity : Vector3 = Vector3.ZERO
var sprint_modifier : float = 0.0
var crouch_modifier : float = 0.0
var speed : float = 0.0
var current_fall_velocity : float
var previous_velocity : Vector3
var current_velocity : Vector2
var direction : Vector3
var wishdir : Vector3

func _physics_process(delta: float) -> void:
	previous_velocity = velocity
	if not is_on_floor():
		velocity += get_gravity() * fall_gravity_multiplier * delta

	var speed_modifier = sprint_modifier
	speed = default_speed + speed_modifier + crouch_modifier
	
	# get all input in one Vector2, representing a direction	
	_input_dir = Input.get_vector("pm_moveleft", "pm_moveright", "pm_moveforward", "pm_movebackward")
	# get current_velocity by extracting x and z from the current _movement_velocity Vector3
	current_velocity = Vector2(_movement_velocity.x, _movement_velocity.z)
	# calculate direction by normalizing the horizontal _input_dir converted to Vector3, with respect to the transform.basis
	direction = (transform.basis * Vector3(_input_dir.x, 0, _input_dir.y)).normalized()

	move_and_slide()
	if is_on_floor():
		step_handler.handle_step_climbing()

## updates player rotation based on a rotation input
## used by CameraController to update the player rotation based on mouse input
func update_rotation(rotation_input) -> void:
	global_transform.basis = Basis.from_euler(rotation_input)

## sets player speed to sprinting
func sprint() -> void:
	sprint_modifier = sprint_speed

## sets player speed to walking
func walk() -> void:
	sprint_modifier = 0.0

## triggers a player crouch
func stand() -> void:
	crouch_modifier = 0.0
	standing_collision.disabled = false
	crouching_collision.disabled = true

## triggers a player crouch
func crouch() -> void:
	if is_on_floor():
		crouch_modifier = crouch_speed
	standing_collision.disabled = true
	crouching_collision.disabled = false

## triggers a player jump
func jump() -> void:
	velocity.y += jump_velocity

## returns true if player is falling at a speed higher than fall_velocity_threshold
## used while player is in airborne state to determine if a camera effect should be 
## played upon hitting the ground
func check_fall_speed() -> bool:
	if current_fall_velocity < fall_velocity_threshold:
		current_fall_velocity = 0.0
		return true
	else:
		current_fall_velocity = 0.0
		return false

func get_input_direction() -> Vector2:
	return _input_dir
