extends KinematicBody2D


func _on_HitBox_body_entered(body):
	if body is Bullet:
		body.queue_free()
		self.queue_free()
