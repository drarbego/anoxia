extends BaseState

func ready(player):
	print("PLAYER IS DETACHED")
	for cell in player.maze.cells:
		cell.set_cost(-1)

func physics_process(_delta, player):
	## reduce player health
	var x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	var y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	var dir = Vector2(x, y).normalized()

	player.move_and_slide(dir * player.speed)
	player.current_cell_index = player.maze.get_cell_index_from_pos(player.position)
