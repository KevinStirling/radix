@tool
class_name Actor 
extends GoldGdt_Pawn

enum ActorFlags {
	PLAYER = 1
}

@export var flags: int = 0 

func _ready() -> void:
	if Engine.is_editor_hint():
		return 
	
	if flags & ActorFlags.PLAYER:
		GAME.set_targetname(Body, "PLAYER")
		print(get_groups())

func _func_godot_apply_properties(props: Dictionary) -> void:
	add_to_group(props["classname"] as String)
	flags = props["flags"] as int
