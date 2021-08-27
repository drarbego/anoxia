extends BaseState

func ready(_player):
	pass

func physics_process(delta, player):
	var x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	var y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	var dir = Vector2(x, y).normalized()
	var new_pos = player.position + dir * player.speed * delta

	if player.maze.is_different_cell(new_pos, player):
		if player.maze.can_move_to_pos(new_pos, player):
			player.move_and_slide(dir * player.speed)
			player.maze.move_to_new_cell(new_pos, player)
	else:
		player.move_and_slide(dir * player.speed)
