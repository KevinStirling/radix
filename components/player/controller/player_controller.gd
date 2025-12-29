class_name PlayerController extends CharacterBody3D

# todo: make this debug value control the enabled flag on state chart debugger w/ get&set
@export var debug : bool = false
@export_category("Movement Settings")
@export_group("Easing")
@export var acceleration : float = 1.0
@export var deceleration : float = 0.5
@export_group("Speed")
@export var default_speed: float = 10.0
@export var sprint_speed : float = 5.0
@export var crouch_speed : float = -5.0
@export_category("Jump Settings")
@export var jump_velocity : float = 5.0
@export_category("References")
@export var state_chart : StateChart
@export var camera : CameraController
@export var standing_collision : CollisionShape3D
@export var crouching_collision : CollisionShape3D
@export var crouch_check : ShapeCast3D
@export var interaction_raycast : RayCast3D

var _input_dir : Vector2 = Vector2.ZERO
var _movement_velocity : Vector3 = Vector3.ZERO
var sprint_modifier : float = 0.0
var crouch_modifier : float = 0.0
var speed : float = 0.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	var speed_modifier = sprint_modifier
	speed = default_speed + speed_modifier + crouch_modifier
	
	# get all input in one Vector2, representing a direction	
	_input_dir = Input.get_vector("pm_moveleft", "pm_moveright", "pm_moveforward", "pm_movebackward")
	# get current_velocity by extracting x and z from the current _movement_velocity Vector3
	var current_velocity = Vector2(_movement_velocity.x, _movement_velocity.z)
	# calculate direction by normalizing the horizontal _input_dir converted to Vector3, with respect to the transform.basis
	var direction = (transform.basis * Vector3(_input_dir.x, 0, _input_dir.y)).normalized()

	if direction:
		current_velocity = lerp(current_velocity, Vector2(direction.x, direction.z) * speed, acceleration)
	else:
		current_velocity = current_velocity.move_toward(Vector2.ZERO, deceleration)

	_movement_velocity = Vector3(current_velocity.x, velocity.y, current_velocity.y)
	
	velocity = _movement_velocity
	move_and_slide()

func update_rotation(rotation_input) -> void:
	global_transform.basis = Basis.from_euler(rotation_input)

func sprint() -> void:
	sprint_modifier = sprint_speed

func walk() -> void:
	sprint_modifier = 0.0

func stand() -> void:
	crouch_modifier = 0.0
	standing_collision.disabled = false
	crouching_collision.disabled = true

func crouch() -> void:
	if is_on_floor():
		crouch_modifier = crouch_speed
	standing_collision.disabled = true
	crouching_collision.disabled = false

func jump() -> void:
	velocity.y += jump_velocity
