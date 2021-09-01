extends KinematicBody2D


var damage = 5.0
export var initial_health_points = 35.0
var health_points = initial_health_points

var is_dying = false
var initial_dying_seconds = 0.5
var dying_seconds = initial_dying_seconds

onready var current_state = $States/Wander
var player = null

var initial_knockback_time = 0.2
var knockback_time = 0.0
var knockback_dir = Vector2.ZERO
var knockback_speed = 500


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

	# TODO needs improvement
	self.knockback_time = self.initial_knockback_time
	self.knockback_dir = (self.global_position - bullet.global_position).normalized()

	self.player = get_node("/root/Maze/Player")
	self.set_state($States/Attack)

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
		$Body.modulate.a = self.dying_seconds / self.initial_dying_seconds
		return
	if knockback_time > 0:
		self.move_and_slide(knockback_dir * knockback_speed)
		knockback_time -= delta
		return

	if self.current_state:
		self.current_state.physics_process(delta, self, self.player)
