extends BaseState


var oxygen_increase = 5

func ready(player):
	player.maze.tube_cells = [player.maze.get_cell_at(player.current_cell_index)]

func physics_process(delta, player):
	player.oxygen_points = clamp(
		player.oxygen_points + (oxygen_increase * delta),
		0,
		player.initial_oxygen_points
	)
	player.update_ui()

	var dir = player.get_dir()
	var speed = player.get_speed()

	var new_pos = player.position + dir * speed * delta

	if player.maze.is_different_cell(new_pos, player):
		if player.maze.can_move_to_pos(new_pos, player):
			player.move_and_slide(dir * speed)
			player.maze.move_to_new_cell(new_pos, player)
	else:
		player.move_and_slide(dir * speed)
