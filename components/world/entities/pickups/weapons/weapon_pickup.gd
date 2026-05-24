class_name WeaponPickup
extends BasePickup

@export var weapon_slot: int = 1
@export var weapon_resource: Weapon


func can_pickup(player: PlayerController) -> bool:
	var weapon_data = Managers.weapon_manager.weapons[weapon_slot]

	# can pickup if: weapon locked or ammo not full
	# return not weapon_data.unlocked or Managers.weapon_manager.get_current_ammo() < weapon_resource.max_ammo
	return not weapon_data.unlocked or weapon_data.ammo < weapon_resource.max_ammo


func apply_pickup(_player: PlayerController) -> void:
	var weapon_data = Managers.weapon_manager.weapons[weapon_slot]

	if weapon_data.unlocked:
		# weapon already owned - refill ammo to max
		weapon_data.ammo = weapon_resource.max_ammo
		print("ammo refilled: ", weapon_resource.weapon_name)
	else:
		Managers.weapon_manager.unlock_weapon(weapon_slot, weapon_resource)
		Managers.weapon_manager.switch_to_slot(weapon_slot)
		print("unlocked: ", weapon_resource.weapon_name)
