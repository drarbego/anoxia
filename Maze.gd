extends BaseMaze

const Player = preload("res://Player.tscn")
# const EnemySpawner = preload("res://EnemySpawner.tscn")
const Enemy = preload("res://Enemy.tscn")
const OxygenDuct = preload("res://OxygenDuct.tscn")
const Bullet = preload("res://Bullet.tscn")


func _ready():
	randomize()
	populate_cells()
	carve_maze(cells[0])
	fill_tilemap()
	fill_cell_content()

	var player = Player.instance().init(
		Vector2(256, 256),
		0,
		self
	)
	add_child(player)
	cells[0].cost = 1

func move_to_new_cell(new_pos, player):
	var new_player_pos = (new_pos / $TileMap.cell_size.x).floor()
	var cell_index = self._get_cell_index(new_player_pos.x, new_player_pos.y)
	if cell_index == null:
		return

	var new_cell = cells[cell_index]
	var previous_cell = cells[player.current_cell_index]

	if new_cell.cost == 1:
		previous_cell.set_cost(-1)
	if new_cell.cost == -1:
		previous_cell.set_cost(1)

	player.current_cell_index = cell_index
	player.move_points += new_cell.cost

	new_cell.set_cost(1)

func is_different_cell(new_pos, player):
	var new_player_pos = (new_pos / $TileMap.cell_size.x).floor()
	var cell_index = self._get_cell_index(new_player_pos.x, new_player_pos.y)
	if cell_index == null:
		return false

	return cell_index != player.current_cell_index

func can_move_to_pos(new_pos, player):
	var new_player_pos = (new_pos / $TileMap.cell_size.x).floor()
	var cell_index = self._get_cell_index(new_player_pos.x, new_player_pos.y)
	if cell_index == null:
		return false

	var cell = cells[cell_index]
	if cell.cost + player.move_points >= 0:
		return true

	return false

func get_cell_at(index):
	if index < 0 or index > (rows * cols) -1:
		return null

	return cells[index]

func spawn_bullet(player):
	var bullet = Bullet.instance().init(
		player.get_node("Gun").global_position,
		(get_global_mouse_position() - player.global_position).normalized()
	)
	add_child(bullet)

func _get_tile_id(cell):
	var walls = str(int(cell.up_wall)) + str(int(cell.right_wall)) + str(int(cell.down_wall)) + str(int(cell.left_wall))
	# Walls are represented as a binary string where each wall is represented clockwise
	# starting by the north wall. The string should be read from left to right
	match walls: # 0000 and 1111 will not exist
		"0001":
			return 0
		"0010":
			return 1
		"0011":
			return 2
		"0100":
			return 3
		"0101":
			return 4
		"0110":
			return 5
		"0111":
			return 6
		"1000":
			return 7
		"1001":
			return 8
		"1010":
			return 9
		"1011":
			return 10
		"1100":
			return 11
		"1101":
			return 12
		"1110":
			return 13

	return -1

func fill_tilemap():
	for cell in cells:
		var tile_id  = self._get_tile_id(cell)
		$TileMap.set_cell(cell.x, cell.y, tile_id)

func fill_cell_content():
	for cell in cells:
		var pos = Vector2(
			(cell.x * $TileMap.cell_size.x) + ($TileMap.cell_size.x / 2),
			(cell.y * $TileMap.cell_size.y) + ($TileMap.cell_size.y / 2)
		)
		if cell.content == CELL_CONTENT.ENEMY_SPAWNER:
			# var enemy_spawner = EnemySpawner.instance()
			# enemy_spawner.position = pos
			# add_child(enemy_spawner)
			var enemy = Enemy.instance()
			enemy.position = pos
			add_child(enemy)
		if cell.content == CELL_CONTENT.OXYGEN_DUCT:
			var oxygen_duct = OxygenDuct.instance()
			oxygen_duct.position = pos
			add_child(oxygen_duct)

func _process(_delta):
	update()

func _draw():
	for cell in cells:
		var color = Color(0, 1, 0.75, 0.25)
		var rect = Rect2(
			cell.x * $TileMap.cell_size.x,
			cell.y * $TileMap.cell_size.y,
			$TileMap.cell_size.x,
			$TileMap.cell_size.y
		)
		if cell.cost == 1:
			draw_rect(
				rect,
				color
			)
