class_name MouseCaptureComponent extends Node

@export var debug : bool = false
@export_category("Mouse Capture Settings")
@export var current_mouse_mode : Input.MouseMode = Input.MOUSE_MODE_CAPTURED
@export var mouse_sensitivity : float = 0.5
# mouse_sens_offset accounts for sens being too high for higher dpi. need to experiement with this
@export var mouse_sens_offset : float = 0.001

var _capture_mouse : bool
var _mouse_input : Vector2

func _unhandled_input(event: InputEvent) -> void:
	_capture_mouse = event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	if _capture_mouse:
		_mouse_input.x += -event.screen_relative.x * (mouse_sensitivity * mouse_sens_offset)
		_mouse_input.y += -event.screen_relative.y * (mouse_sensitivity * mouse_sens_offset)

func _ready() -> void:
	Input.mouse_mode = current_mouse_mode

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("db_mouse_toggle") and debug:
		match current_mouse_mode:
			Input.MOUSE_MODE_CAPTURED:
				current_mouse_mode = Input.MOUSE_MODE_VISIBLE
			Input.MOUSE_MODE_VISIBLE:
				current_mouse_mode = Input.MOUSE_MODE_CAPTURED

	Input.mouse_mode = current_mouse_mode
	_mouse_input = Vector2.ZERO

