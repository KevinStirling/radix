class_name Math extends Node

## frame rate independant lerp
static func exp_decay_f(a: float, b: float, decay: float, delta: float) -> float:
	return b + (a - b) * exp(-decay * delta)

## frame rate independant player velocity lerp
static func exp_decay_velo(a: Vector2, b: Vector2, decay: float, delta: float) -> Vector2:
	return a + (b - a) * exp(-decay * delta)
