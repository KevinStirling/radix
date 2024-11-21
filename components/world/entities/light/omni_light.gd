extends OmniLight3D

@export var func_godot_properties : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(func_godot_properties.get("is_test"))
	EventBus.trigger_target_event.connect(toggle)

func toggle(targetName : String) :
	if targetName == func_godot_properties.get("name"):
		visible = !visible
