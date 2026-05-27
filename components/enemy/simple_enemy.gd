class_name SimpleEnemy
extends Enemy

@export var follow_speed: float = 3.0
@export var fall_gravity_multiplier = 1.5

var target: Node3D

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var state_chart: StateChart = $StateChart
@onready var health_component: HealthComponent = $HealthComponent
@onready var animation_player: AnimationPlayer = $placeholder_enemy/AnimationPlayer


func _ready():
	super._ready()

	target = get_tree().get_first_node_in_group("player")

	health_component.died.connect(_on_died)
	nav_agent.velocity_computed.connect(_on_velocity_computed)

	if animation_player:
		animation_player.play("Idle")
		animation_player.seek(randf_range(0, animation_player.current_animation_length))


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		# TODO: might want to expose the fall_gravity_multiplier as a cvar that every node can look up
		velocity += get_gravity() * fall_gravity_multiplier * delta

	move_and_slide()


func on_triggered() -> void:
	state_chart.send_event("toFollow")


func _on_died() -> void:
	queue_free()


func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z


func _on_follow_state_physics_processing(delta: float) -> void:
	if not target:
		return

	nav_agent.target_position = target.global_position

	# check if nav is finsihed
	if nav_agent.is_navigation_finished():
		nav_agent.velocity = Vector3.ZERO
		if animation_player and animation_player.current_animation != "Idle":
			animation_player.play("Idle")
		return

	# get next position in path
	var next_pos = nav_agent.get_next_path_position()
	var direction = (next_pos - global_position).normalized()

	# set desired velo
	nav_agent.velocity = direction * follow_speed

	if animation_player and animation_player.current_animation != "Walk":
		animation_player.play("Walk")

	# rotate to face move direction
	if direction.length() > 0.01:
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 5.0 * delta)


func _on_detection_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		on_triggered()
