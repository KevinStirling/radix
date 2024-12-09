@tool
class_name LightOmni
extends OmniLight3D

@export var targetname : String

func _func_godot_apply_properties(props: Dictionary) -> void:
	LightBase._func_godot_apply_properties(self, props)
	omni_range = (props["range"] as float) * GAME.INVERSE_SCALE
	targetname = props["targetname"] as String

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	GAME.set_targetname(self, targetname)

func use() -> void:
	print("use light")
	visible = true
