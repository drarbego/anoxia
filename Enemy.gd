extends KinematicBody2D


var damage = 5.0
export var initial_health_points = 35.0
var health_points = initial_health_points

var is_dying = false
var dying_seconds = 2.0

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
		self._handle_damage(body)

func _handle_damage(bullet: Bullet):
	self.health_points -= bullet.damage
	self.update_ui()

	if self.health_points <= 0:
		self._die()

func update_ui():
	$HealthBar.set_value(
		(self.health_points / self.initial_health_points) * $HealthBar.max_value
	)

func _die():
	self.is_dying = true

func _physics_process(delta):
	if dying_seconds <= 0:
		self.queue_free()
	if is_dying:
		self.dying_seconds -= delta
		return

	if self.current_state:
		self.current_state.physics_process(delta, self, self.player)
