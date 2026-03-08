class_name PlayerStateMachine extends Node

@export var debug : bool = false
@export_category("References")
@export var player : PlayerController

func _process(_delta) -> void:
	if player:
		# debug ui expressions
		player.state_chart.set_expression_property("Player speed", player.speed)
		player.state_chart.set_expression_property("Player Velocity", player.velocity)
		player.state_chart.set_expression_property("Player Head Collision", player.crouch_check.is_colliding())
		player.state_chart.set_expression_property("Camera Rotation", player.camera._rotation)
		player.state_chart.set_expression_property("Looking at", player.interaction_raycast.current_object)
		player.state_chart.set_expression_property("Step Status", player.step_handler.step_status)

func _physics_process(_delta: float) -> void:
	player.state_chart.set_expression_property("Mouse input", player.camera.component_mouse_capture._mouse_input)
	player.state_chart.set_expression_property("Input direction", player.get_input_direction())
	player.state_chart.set_expression_property("Move velocity", player.velocity.length())
