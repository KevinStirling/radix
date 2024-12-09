extends Control

signal toggle(action:String, on:bool)

@onready var comms_toggle = %CommsButton

var parent = get_parent()

# TODO BUG after player interacts with screen, some inputs like UI accept (space) are still getting 
# picked up after walking away

# Called when the node enters the scene tree for the first time.
func _ready():
	comms_toggle.toggled.connect(_toggle)
	

func _toggle(on : bool) :
	toggle.emit("comms", on)
