class_name Weapon
extends Resource

@export var weapon_name: String = "Pistol"
@export var damage: float = 25.0
@export var max_ammo: int = 12
@export var fire_rate: float = 2.0
@export var is_automatic: bool = false
@export var max_range: float = 25.0
@export_range(0, 100) var accuracy: int = 100
@export var is_hitscan: bool = true
@export var projectile_speed: float = 50.0
@export var weapon_model: PackedScene
@export var projectile_scene: PackedScene
@export var pellet_count: int = 1
@export var spread_angle: float = 0.0
@export var weapon_position: Vector3 = Vector3(0.2, -0.2, -0.3)
@export_group("Recoil")
@export var recoil_cam_pitch: float = 1.0
@export var recoil_cam_yaw: float = 0.25
@export var recoil_cam_roll: float = 0.0
@export var recoil_model_kickback: float = 0.02
@export var recoil_model_rise: float = 8.0
@export_group("Vertical lag")
@export var vertical_lag_amount: float = 2.0
