extends RayCast3D

@onready var hint_label : Label = $UI/Control/HintLabel
var interacting : bool :
	get:
		return interacting
	set(value):
		interacting = value
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
