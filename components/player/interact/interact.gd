extends RayCast3D

# This is my older version of an Interact Raycast
# It was specifically designed to be used ONLY with the terminal component I made
# It should be reworked to be more modular

@onready var hint_label : Label = $UI/Control/HintLabel
var interacting : bool :
	get:
		return interacting
	set(value):
		interacting = value
		# mouse mode switching should be done ON the object being interacted WITH
		# each interactable should have an interact() func that handles stuff like this
		# also use camera.component_mouse_capture.current_mouse_mode rather than Input.mouse_mode directly
		if interacting == false:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else :
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			hide_hint()

# Called when the node enters the scene tree for the first time.
func _ready():
	interacting = false
	
# Interaction Hints
func show_hint(c : Object) -> void :
	hint_label.text = "[e] to use " 

func hide_hint() -> void :
	hint_label.text = ""

func _input(event):
	if Input.is_action_just_pressed("interact") && is_colliding():
		if !interacting:
			interacting = true
		else:
			interacting = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_colliding() && !interacting:
		show_hint(get_collider())
	elif !is_colliding() && !interacting:
		hide_hint()
	elif !is_colliding() && interacting:
		# if player walks away while interacting, leave interaction mode
		interacting = false
