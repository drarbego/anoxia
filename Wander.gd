extends Node

var dir = Vector2.ZERO
var speed = 200


func _get_random_dir():
	match randi() % 4:
		0:
			return Vector2.LEFT
		1:
			return Vector2.RIGHT
		2:
			return Vector2.UP
		3:
			return Vector2.DOWN

	return Vector2.ZERO

func ready(enemy):
	self.dir = _get_random_dir()
	enemy.get_node("WanderTimer").start()

func physics_process(delta, enemy, _player):
	var collision = enemy.move_and_collide(self.dir * self.speed * delta)
	if collision:
		self.dir=_get_random_dir()
