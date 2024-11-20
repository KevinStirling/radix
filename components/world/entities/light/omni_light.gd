extends OmniLight3D

@export var func_godot_properties : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(func_godot_properties.get("is_test"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
