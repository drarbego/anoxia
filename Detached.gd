extends BaseState


var oxygen_decrease = 5

func ready(player):
	for cell in player.maze.cells:
		cell.set_cost(-1)

func physics_process(delta, player):
	player.oxygen_points = clamp(
		player.oxygen_points - (oxygen_decrease * delta),
		0,
		player.initial_oxygen_points
	)
	player.update_ui()
	if player.oxygen_points <= 0:
		player.set_game_over(true)

	var dir = player.get_dir()
	var speed = player.get_speed()

	player.move_and_slide(dir * speed)
	player.current_cell_index = player.maze.get_cell_index_from_pos(player.position)
