class_name Math extends Node

## frame rate independant version of lerp
static func exp_decay_f(a: float, b: float, decay: float, delta: float) -> float:
	return b + (a - b) * exp(-decay * delta)
