class_name AmmoPickup
extends BasePickup

@export var weapon_slot: int = 1
@export var ammo_amount: int = 10


func can_pickup(_player: PlayerController) -> bool:
	if weapon_slot not in Managers.weapon_manager.weapons:
		return false

	var weapon_data = Managers.weapon_manager.weapons[weapon_slot]

	print(weapon_data.unlocked and weapon_data.ammo < weapon_data.weapon.max_ammo)
	return weapon_data.unlocked and weapon_data.ammo < weapon_data.weapon.max_ammo


func apply_pickup(_player: PlayerController) -> void:
	var weapon_data = Managers.weapon_manager.weapons[weapon_slot]

	# calculate how much ammo to add
	var space_available = weapon_data.weapon.max_ammo - weapon_data.ammo
	var ammo_to_add = min(ammo_amount, space_available)

	# add ammo
	weapon_data.ammo += ammo_to_add
	print("picked up ", ammo_to_add, " ammo for ", weapon_data.weapon.weapon_name)
