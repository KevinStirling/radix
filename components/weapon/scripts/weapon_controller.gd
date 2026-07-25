class_name WeaponController
extends Node

@export var player: CharacterBody3D
@export var camera: Camera3D
@export var weapon_model_parent: Node3D
@export var weapon_state_chart: StateChart
@export_group("Idle Sway")
@export var idle_sway_frequency: float = 0.8
@export var idle_sway_amplitude: Vector2 = Vector2(0.03, 0.02)
@export var idle_sway_stiffness: float = 20.0
@export var idle_sway_damping: float = 10.0

var current_weapon_model: Node3D
var fire_rate_timer: float = 0.0
var can_fire_next: bool = true
var current_weapon: Weapon
var base_weapon_position: Vector3
var idle_time: float = 0.0
var _idle_x: float = 0.0
var _idle_y: float = 0.0
var _idle_x_vel: float = 0.0
var _idle_y_vel: float = 0.0


func _ready():
	if current_weapon:
		spawn_weapon_model()


func _process(delta: float) -> void:
	if fire_rate_timer > 0:
		fire_rate_timer -= delta
		if fire_rate_timer <= 0:
			can_fire_next = true

	_update_idle_sway(delta)


func spawn_weapon_model():
	if current_weapon_model:
		current_weapon_model.queue_free()

	if current_weapon.weapon_model:
		current_weapon_model = current_weapon.weapon_model.instantiate()
		weapon_model_parent.add_child(current_weapon_model)
		current_weapon_model.position = current_weapon.weapon_position

		# store for offset animations
		base_weapon_position = current_weapon.weapon_position


func can_fire() -> bool:
	var weapon_data = Managers.weapon_manager.weapons[Managers.weapon_manager.current_slot]
	return weapon_data.ammo > 0 and can_fire_next


func fire_weapon() -> void:
	if can_fire():
		Managers.weapon_manager.use_ammo(Managers.weapon_manager.current_slot)
		var kick_pitch = current_weapon.damage * camera.weapon_kick_pitch_limit
		camera.add_weapon_kick(kick_pitch, kick_pitch / 2.0, 1.0)
		print("Fired! Ammo: ", Managers.weapon_manager.get_current_ammo())

		# start fire rate cooldown
		can_fire_next = false
		fire_rate_timer = 1.0 / current_weapon.fire_rate

	if current_weapon.is_hitscan:
		_perform_hitscan()
	else:
		_spawn_projectile()


func switch_weapon(weapon_data: WeaponData) -> void:
	current_weapon = weapon_data.weapon

	if current_weapon_model:
		current_weapon_model.queue_free()

	spawn_weapon_model()

	weapon_state_chart.send_event("onIdle")

	print(current_weapon.weapon_name)


func has_ammo() -> bool:
	# var weapon_data = Managers.weapon_manager.weapons[Managers.weapon_manager.current_slot]
	return Managers.weapon_manager.get_current_ammo() > 0


func _perform_hitscan() -> void:
	if not camera:
		print("no camera assigned")
		return

	var space_state = camera.get_world_3d().direct_space_state
	var from = camera.global_position

	for i in current_weapon.pellet_count:
		var forward = -camera.global_transform.basis.z

		# calculate accuracy spread (inverse relationship)
		var accuracy_spread = (100 - current_weapon.accuracy) / 1000.0

		# add accuracy randomness
		var accuracy_x = randf_range(-accuracy_spread, accuracy_spread)
		var accuracy_y = randf_range(-accuracy_spread, accuracy_spread)
		var direction = forward + Vector3(accuracy_x, accuracy_y, 0)

		# add pelet spread if multiple pellets
		if current_weapon.pellet_count > 1:
			var spread_x = randf_range(-current_weapon.spread_angle, current_weapon.spread_angle)
			var spread_y = randf_range(-current_weapon.spread_angle, current_weapon.spread_angle)
			# direction multiplied by camera.global_transform.basis, so the random
			# accuracy is relative to where the player is facing
			direction += Vector3(spread_x, spread_y, 0) * camera.global_transform.basis

		var to = from + direction * current_weapon.max_range

		var query = PhysicsRayQueryParameters3D.create(from, to)
		# you can change collision mask here to restrict what mesh layers are hit
		# query.collision_mask = 1
		var result = space_state.intersect_ray(query)

		if result:
			print("Hit: ", result.collider.name, " at ", result.position)
			_spawn_impact_marker(result.position)
			_apply_damage_to_target(result.collider)


## Tries to apply damage(if applicable) to a Node3D
func _apply_damage_to_target(target: Node3D) -> void:
	# not the perfect solution to this, but good enough for concepting
	# with this method, HealthComponent must always have this name and
	# always be a direct child of the root scene node
	# check if target has HealthComponent
	var health_component = target.get_node_or_null("HealthComponent")

	if health_component and health_component.has_method("take_damage"):
		health_component.take_damage(current_weapon.damage, owner)


## Debug function to visualize where a hitscan weapon hits
func _spawn_impact_marker(position: Vector3) -> void:
	var marker = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.1, 0.1, 0.1)
	marker.mesh = box

	var material = StandardMaterial3D.new()
	material.albedo_color = Color.RED
	marker.set_surface_override_material(0, material)

	get_tree().current_scene.add_child(marker)
	marker.global_position = position

	get_tree().create_timer(2.0).timeout.connect(marker.queue_free)


func _spawn_projectile() -> void:
	if not current_weapon.projectile_scene:
		print("no projectile scnee assigned")
		return

	if not camera:
		print("no camera assigned")
		return

	# spawn projectile and position at camera
	var projectile = current_weapon.projectile_scene.instantiate() as Projectile
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = camera.global_position

	# calculate direction and velocity
	var forward = -camera.global_transform.basis.z

	# add accuracy randomness
	var accuracy_spread = (100 - current_weapon.accuracy) / 1000.0
	var accuracy_x = randf_range(-accuracy_spread, accuracy_spread)
	var accuracy_y = randf_range(-accuracy_spread, accuracy_spread)
	# direction multiplied by camera.global_transform.basis, so the random
	# accuracy is relative to where the player is facing
	var direction = forward + Vector3(accuracy_x, accuracy_y, 0) * camera.global_transform.basis

	var velocity = direction * current_weapon.projectile_speed

	projectile.look_at(projectile.global_position + direction, Vector3.UP)

	# setup projectile
	projectile.setup(velocity, current_weapon.damage)


func _update_idle_sway(delta: float) -> void:
	if not current_weapon_model:
		return
	# increment time
	idle_time += delta

	var speed = Vector2(player.velocity.x, player.velocity.y).length()
	var target_x := 0.0
	var target_y := 0.0

	if speed < 0.1:
		# calculate sine wave targets (figure-8 pattern)
		target_x = sin(idle_time * idle_sway_frequency) * idle_sway_amplitude.x
		# 0.618 used as "golden ratio" to prevent animation from lining up with the x
		target_y = sin(idle_time * idle_sway_frequency * 0.618) * idle_sway_amplitude.y

	# apply spring to x axis
	var result_x = SpringUtil.apply(
		_idle_x,
		_idle_x_vel,
		target_x,
		idle_sway_stiffness,
		idle_sway_damping,
		delta,
	)
	_idle_x = result_x.x
	_idle_x_vel = result_x.y

	var result_y = SpringUtil.apply(
		_idle_y,
		_idle_y_vel,
		target_y,
		idle_sway_stiffness,
		idle_sway_damping,
		delta,
	)
	_idle_y = result_y.y
	_idle_y_vel = result_y.y

	# apply offset to weapon
	var idle_offset = Vector3(_idle_x, _idle_y, 0.0)
	current_weapon_model.position = base_weapon_position + idle_offset
