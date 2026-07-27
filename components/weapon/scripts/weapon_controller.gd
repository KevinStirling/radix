class_name WeaponController
extends Node

@export var player: CharacterBody3D
@export var camera: CameraEffects
@export var camera_rig: CameraController
@export var weapon_model_parent: Node3D
@export var weapon_state_chart: StateChart
@export_group("Visual Juice")
@export var idle_sway: bool = true
@export var look_sway: bool = true
@export var strafe_tilt: bool = true
@export var weapon_bob: bool = true
@export var vertical_lag: bool = true
@export_group("Idle Sway")
@export var idle_sway_frequency: float = 0.8
@export var idle_sway_amplitude: Vector2 = Vector2(0.03, 0.02)
@export var idle_sway_stiffness: float = 20.0
@export var idle_sway_damping: float = 10.0
@export_group("Look Sway")
@export var look_lag_divisor: float = 10.0
@export var look_lag_rot_max: float = 5.0
@export var look_lag_pos_scale: float = 0.006
@export_group("Strafe tilt")
@export var strafe_tilt_scale: float = 0.3
@export var strafe_tilt_max: float = 0.08
@export var strafe_tilt_stiffness: float = 80.0
@export var strafe_tilt_damping: float = 10.0
@export_group("Weapon bob")
@export var weapon_bob_amplitude: Vector2 = Vector2(0.02, 0.012)
@export var bob_max_speed: float = 10.0
@export var bob_stiffness: float = 60.0
@export var bob_damping: float = 10.0
@export_group("Recoil")
@export var recoil: bool = true
@export var recoil_model_stiffness: float = 200.0
@export var recoil_model_damping: float = 11.0
@export var recoil_model_max: float = 0.15
@export var recoil_pitch_max: float = 0.4
@export_group("Vertical lag")
@export var vlag_stiffness: float = 60.0
@export var vlag_damping: float = 12.0
@export var vlag_deadzone: float = 0.05
@export var vlag_max: float = 0.1
@export var vlag_velo_max: float = 10.0

var current_weapon_model: Node3D
var fire_rate_timer: float = 0.0
var can_fire_next: bool = true
var current_weapon: Weapon
# Idle sway
var base_weapon_position: Vector3
var base_weapon_rotation: Vector3
var idle_time: float = 0.0
var _idle_x: float = 0.0
var _idle_y: float = 0.0
var _idle_x_vel: float = 0.0
var _idle_y_vel: float = 0.0
# Weapon bob
var _bob_x: float = 0.0
var _bob_y: float = 0.0
var _bob_x_vel: float = 0.0
var _bob_y_vel: float = 0.0
# Look sway
var _prev_camera_rotation: Vector3 = Vector3.ZERO
var _cam_rot_rate: Vector3 = Vector3.ZERO
# Strafe tilt
var _strafe_tilt: float = 0.0
var _strafe_tilt_velo: float = 0.0
# Recoil
var _recoil_z: float = 0.0
var _recoil_z_vel: float = 0.0
var _recoil_pitch: float = 0.0
var _recoil_pitch_vel: float = 0.0
# Lag
var _vlag_y: float = 0.0
var _vlag_y_vel: float = 0.0
var _prev_camera_y: float = 0.0
var _vlag_seeded: bool = false


func _ready():
	if current_weapon:
		spawn_weapon_model()


func _process(delta: float) -> void:
	if fire_rate_timer > 0:
		fire_rate_timer -= delta
		if fire_rate_timer <= 0:
			can_fire_next = true

	_apply_offsets(delta)


func spawn_weapon_model():
	if current_weapon_model:
		current_weapon_model.queue_free()

	if current_weapon.weapon_model:
		current_weapon_model = current_weapon.weapon_model.instantiate()
		weapon_model_parent.add_child(current_weapon_model)
		current_weapon_model.position = current_weapon.weapon_position

		# store for offset animations
		base_weapon_position = current_weapon.weapon_position
		base_weapon_rotation = Vector3.ZERO

		# reset bob
		_bob_x = 0.0
		_bob_y = 0.0
		_bob_x_vel = 0.0
		_bob_y_vel = 0.0

		# reset recoil
		_recoil_z = 0.0
		_recoil_z_vel = 0.0
		_recoil_pitch = 0.0
		_recoil_pitch_vel = 0.0


func can_fire() -> bool:
	var weapon_data = Managers.weapon_manager.weapons[Managers.weapon_manager.current_slot]
	return weapon_data.ammo > 0 and can_fire_next


func fire_weapon() -> void:
	if can_fire():
		Managers.weapon_manager.use_ammo(Managers.weapon_manager.current_slot)
		# var kick_pitch = current_weapon.damage * camera.weapon_kick_pitch_limit
		print("Fired! Ammo: ", Managers.weapon_manager.get_current_ammo())

		# camera recoil
		if camera:
			camera.add_weapon_kick(
				current_weapon.recoil_cam_pitch,
				current_weapon.recoil_cam_yaw,
				current_weapon.recoil_cam_roll,
			)

		# weapon recoil
		if recoil:
			_add_model_recoil()

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


# applies combined weapon offsets based on controller input
func _apply_offsets(delta: float) -> void:
	var idle_offset = _update_idle_sway(delta) if idle_sway else Vector3.ZERO
	var look_offset = _update_look_sway(delta) if look_sway else Vector3.ZERO
	var bob_offset = _update_bob(delta) if weapon_bob else Vector3.ZERO
	var vlag_offset = _update_vertical_lag(delta) if vertical_lag else Vector3.ZERO

	var tilt = Vector3(0.0, 0.0, _update_tilt(delta) if strafe_tilt else 0.0)
	var recoil_pos = Vector3.ZERO
	var recoil_pitch = 0.0
	if recoil:
		recoil_pos = _update_recoil(delta)
		recoil_pitch = _recoil_pitch

	current_weapon_model.position = base_weapon_position + idle_offset + look_offset + bob_offset + recoil_pos + vlag_offset
	current_weapon_model.rotation = base_weapon_rotation + tilt + Vector3(recoil_pitch, 0.0, 0.0)


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


func _update_idle_sway(delta: float) -> Vector3:
	if not current_weapon_model:
		return Vector3.ZERO
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

	return idle_offset


func _update_look_sway(delta: float) -> Vector3:
	if not camera:
		return Vector3.ZERO

	var cam_rot = camera.global_rotation

	# calculate rotation delta (how much camera rotated this frame)
	var rot_delta = cam_rot - _prev_camera_rotation
	_prev_camera_rotation = cam_rot

	# clamp rotation delta to max tracking amount
	var max_rad = deg_to_rad(look_lag_rot_max)
	rot_delta.x = clamp(rot_delta.x, -max_rad, max_rad)
	rot_delta.y = clamp(rot_delta.y, -max_rad, max_rad)
	rot_delta.z = 0.0 # ignore roll

	# smooth the rotation rate (frame independant)
	var interp_speed = (1.0 / delta) / look_lag_divisor
	_cam_rot_rate = _cam_rot_rate.lerp(rot_delta, clamp(interp_speed * delta, 0.0, 1.0))

	# derive position offset from rotation rate
	var norm_pitch = _cam_rot_rate.x / max_rad if max_rad > 0.0 else 0.0
	var norm_yaw = _cam_rot_rate.y / max_rad if max_rad > 0.0 else 0.0
	var look_pos = Vector3(
		norm_yaw * look_lag_pos_scale,
		norm_pitch * -look_lag_pos_scale,
		0.0,
	)

	return look_pos


func _update_tilt(delta: float) -> float:
	if not player or not camera:
		return 0.0

	# convert player velo to camera-local space
	var local_velocity = camera.global_transform.basis.inverse() * player.velocity

	# get horiz movement (x and z in local space)
	var xz = Vector2(local_velocity.x, local_velocity.y)
	var xz_speed = xz.length()

	var lateral_fraction = abs(xz.x) / xz_speed if xz_speed > 0.1 else 0.0

	# calcuate tilt target
	var tilt_target = clamp(
		-local_velocity.x * lateral_fraction * strafe_tilt_scale,
		-strafe_tilt_max,
		strafe_tilt_max,
	)

	# apply spring
	var result = SpringUtil.apply(
		_strafe_tilt,
		_strafe_tilt_velo,
		tilt_target,
		strafe_tilt_stiffness,
		strafe_tilt_damping,
		delta,
	)

	_strafe_tilt = result.x
	_strafe_tilt_velo = result.y

	return _strafe_tilt


func _update_bob(delta: float) -> Vector3:
	if not current_weapon_model or not camera or not player:
		return Vector3.ZERO

	var phase := camera.get_bob_phase()
	var speed := Vector2(player.velocity.x, player.velocity.z).length()

	var target_x := 0.0
	var target_y := 0.0

	if speed > 0.1:
		var speed_factor: float = clamp(speed / bob_max_speed, 0.0, 1.0)
		# create the "figure 8" shape
		var angle := phase * TAU

		target_x = sin(angle) * weapon_bob_amplitude.x * speed_factor
		target_y = sin(angle * 2.0) * weapon_bob_amplitude.y * speed_factor

	var result_x := SpringUtil.apply(_bob_x, _bob_x_vel, target_x, bob_stiffness, bob_damping, delta)
	_bob_x = result_x.x
	_bob_x_vel = result_x.y

	var result_y := SpringUtil.apply(_bob_y, _bob_y_vel, target_y, bob_stiffness, bob_damping, delta)
	_bob_y = result_y.y
	_bob_y_vel = result_y.y

	return Vector3(_bob_x, _bob_y, 0.0)


func _add_model_recoil() -> void:
	_recoil_z += current_weapon.recoil_model_kickback
	_recoil_pitch += deg_to_rad(current_weapon.recoil_model_rise)


func _update_recoil(delta: float) -> Vector3:
	# kickback
	var rz = SpringUtil.apply(_recoil_z, _recoil_z_vel, 0.0, recoil_model_stiffness, recoil_model_damping, delta)
	_recoil_z = clamp(rz.x, -recoil_model_max, recoil_model_max)
	_recoil_z_vel = rz.y

	# muzzle rise
	var rp = SpringUtil.apply(_recoil_pitch, _recoil_pitch_vel, 0.0, recoil_model_stiffness, recoil_model_damping, delta)
	_recoil_pitch = clamp(rp.x, -recoil_pitch_max, recoil_pitch_max)
	_recoil_pitch_vel = rp.y

	return Vector3(0.0, 0.0, _recoil_z)


func _update_vertical_lag(delta: float) -> Vector3:
	if not camera_rig or not current_weapon_model:
		return Vector3.ZERO

	var cam_y = camera_rig.global_position.y

	if not _vlag_seeded:
		# prevent unwanted camera jitter on player spawn
		_prev_camera_y = cam_y
		_vlag_seeded = true
		return Vector3.ZERO

	var cam_vel_y = (cam_y - _prev_camera_y) / delta
	_prev_camera_y = cam_y

	cam_vel_y = clamp(cam_vel_y, -vlag_max, vlag_max)
	if abs(cam_vel_y) < vlag_deadzone:
		# if cam_vel_y is inside deadzone, apply no animation
		cam_vel_y = 0.0

	# set the target to negative of the cam_velo for the "lag behind" effect
	var target_y = -cam_vel_y * current_weapon.vertical_lag_amount
	var result = SpringUtil.apply(_vlag_y, _vlag_y_vel, target_y, vlag_stiffness, vlag_damping, delta)
	_vlag_y = clamp(result.x, -vlag_max, vlag_max)
	_vlag_y_vel = result.y

	return Vector3(0.0, _vlag_y, 0.0)
