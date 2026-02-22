class_name EngineParameters extends Resource

@export_group("Engine Agnostic Variables")
@export var ACCELERATION : float = 10.0 ## The base acceleration amount that is multiplied by [code]wishspeed[/code] inside of [method _accelerate]. The default value equals 10.
@export var AIR_ACCELERATION : float = 10.0 ## The base acceleration amount that is multiplied by [code]wishspeed[/code] inside of [method _airaccelerate]. The default value equals 10.
@export var FRICTION : float = 4.0 ## The multiplier of dropped speed when friction is acting on the player. The default value equals 4.
