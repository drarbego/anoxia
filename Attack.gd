extends Node


var speed = 300
var is_cooled_down = true

func _on_CooldownTimer_timeout():
	self.is_cooled_down = true

func ready(enemy):
	enemy.get_node("WanderTimer").stop()

func physics_process(_delta, enemy, player):
	if not is_instance_valid(player) or player.game_over:
		enemy.set_state(enemy.get_node("States/Wander"))
		return

	var to_player_vec = player.global_position - enemy.global_position 
	var dist_to_player = to_player_vec.length()
	if self.is_cooled_down and dist_to_player <= (enemy.get_node("HitBox/CollisionShape2D").shape.radius * 1.3):
		player.receive_attack(to_player_vec.normalized(), enemy.damage)
		self.is_cooled_down = false
		enemy.get_node("CooldownTimer").start()
	else:
		enemy.move_and_slide(to_player_vec.normalized() * self.speed)


