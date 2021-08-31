extends Area2D

func _on_OxygenDuct_body_entered(body):
	if body is Player:
		body.is_near_oxygen_duct = true
		print("body.is_near_oxygen_duct ", body.is_near_oxygen_duct)

func _on_OxygenDuct_body_exited(body):
	if body is Player:
		body.is_near_oxygen_duct = false
