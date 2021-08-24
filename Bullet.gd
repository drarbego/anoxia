extends KinematicBody2D

var dir = Vector2.ZERO
var speed = 1600

func init(_pos, _dir):
	self.position = _pos
	self.dir = _dir
	return self

func _physics_process(delta):
	var collision = move_and_collide(dir * speed * delta)
	if collision:
		self.queue_free()
