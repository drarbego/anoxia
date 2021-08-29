extends KinematicBody2D


var damage = 15

onready var current_state = $States/Wander
var player = null


func set_state(new_state):
	if new_state == $States/Wander:
		self.current_state = new_state
		self.current_state.ready(self)
	if new_state == $States/Attack:
		self.current_state = new_state
		self.current_state.ready(self)
	
func _on_DetectionArea_body_entered(body):
	if body is Player:
		self.player = body
		self.set_state($States/Attack)

func _on_DetectionArea_body_exited(body):
	if body is Player:
		self.set_state($States/Wander)

func _on_WanderTimer_timeout():
	self.set_state($States/Wander)

func _on_HitBox_body_entered(body):
	if body is Bullet:
		body.queue_free()
		self.queue_free()

func _physics_process(delta):
	if self.current_state:
		self.current_state.physics_process(delta, self, self.player)

