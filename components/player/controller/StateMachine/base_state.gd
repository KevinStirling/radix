class_name PlayerState extends Node

@export var debug : bool = false

var player : PlayerController

func _ready() -> void:
	if %StateMachine and %StateMachine is PlayerStateMachine:
		player = %StateMachine.player
