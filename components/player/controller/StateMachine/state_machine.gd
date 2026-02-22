class_name PlayerStateMachine extends Node

@export var debug : bool = false
@export_category("References")
@export var player_controller : PlayerController

func _process(_delta) -> void:
	if player_controller:
		# debug ui expressions
		player_controller.state_chart.set_expression_property("Player speed", player_controller.speed)
		player_controller.state_chart.set_expression_property("Player Velocity", player_controller.velocity)
		player_controller.state_chart.set_expression_property("Player Head Collision", player_controller.crouch_check.is_colliding())
		player_controller.state_chart.set_expression_property("Camera Rotation", player_controller.camera._rotation)
		player_controller.state_chart.set_expression_property("Looking at", player_controller.interaction_raycast.current_object)
		player_controller.state_chart.set_expression_property("Step Status", player_controller.step_handler.step_status)

func _physics_process(_delta: float) -> void:
	player_controller.state_chart.set_expression_property("Mouse input", player_controller.camera.component_mouse_capture._mouse_input)
	player_controller.state_chart.set_expression_property("Input direction", player_controller.get_input_direction())
	player_controller.state_chart.set_expression_property("Move velocity", player_controller._movement_velocity)
