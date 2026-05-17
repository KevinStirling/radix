extends WeaponState


func _on_empty_state_entered() -> void:
	print("weapon empty!")


func _on_empty_state_processing(_delta: float) -> void:
	pass
