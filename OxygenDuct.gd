extends Area2D

func _on_OxygenDuct_body_entered(body):
	if body is Player:
		body.is_near_oxygen_duct = true

func _on_OxygenDuct_body_exited(body):
	if body is Player:
		body.is_near_oxygen_duct = false
