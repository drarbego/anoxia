extends KinematicBody2D

class_name Bullet

var dir = Vector2.ZERO
var speed = 1600.0
var damage = 5.0


func init(_pos, _dir):
	self.position = _pos
	self.dir = _dir
	$Sprite.rotation = self.dir.angle()
	return self

func _physics_process(delta):
	var collision = move_and_collide(dir * speed * delta)
	if collision:
		self.queue_free()
