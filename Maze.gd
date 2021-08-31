extends BaseMaze

const Player = preload("res://Player.tscn")
const EnemySpawner = preload("res://EnemySpawner.tscn")
const OxygenDuct = preload("res://OxygenDuct.tscn")
const Bullet = preload("res://Bullet.tscn")
const Item = preload("res://Item.tscn")

var tube_cells = []

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
	self.tube_cells.append(cells[0])

func move_to_new_cell(new_pos, player):
	var new_player_pos = (new_pos / $TileMap.cell_size.x).floor()
	var cell_index = self._get_cell_index(new_player_pos.x, new_player_pos.y)
	if cell_index == null:
		return

	var new_cell = cells[cell_index]
	var previous_cell = cells[player.current_cell_index]

	previous_cell.set_cost(new_cell.cost * -1)

	player.current_cell_index = cell_index
	player.move_points += new_cell.cost

	new_cell.set_cost(1)

	# --- TODO IMPROVE THIS CODE
	var tube_cells_count = len(self.tube_cells)

	if not new_cell in self.tube_cells:
		self.tube_cells.append(new_cell)
	elif tube_cells_count and previous_cell == self.tube_cells[tube_cells_count - 1]:
		self.tube_cells.pop_back()

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
	match walls: # 1111 will not exist
		"0000":
			return 14
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

	print("Resulting cell walls ", walls, "did not match")
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
			var enemy_spawner = EnemySpawner.instance()
			enemy_spawner.position = pos
			add_child(enemy_spawner)
		if cell.content == CELL_CONTENT.OXYGEN_DUCT:
			var oxygen_duct = OxygenDuct.instance()
			oxygen_duct.position = pos
			add_child(oxygen_duct)
		if cell.content == CELL_CONTENT.ITEMS:
			var item = Item.instance()
			item.position = pos
			add_child(item)

func _process(_delta):
	update()

func _draw():
	if self.tube_cells:
		var previous_cell = self.tube_cells[0]
		for cell in self.tube_cells.slice(1, len(self.tube_cells) -2):
			var start = Vector2(
				previous_cell.x * $TileMap.cell_size.x + $TileMap.cell_size.x / 2,
				previous_cell.y * $TileMap.cell_size.y + $TileMap.cell_size.y / 2
			)
			var end = Vector2(
				cell.x * $TileMap.cell_size.x + $TileMap.cell_size.x / 2,
				cell.y * $TileMap.cell_size.y + $TileMap.cell_size.y / 2
			)
			draw_line(
				start,
				end,
				Color(0, 0, 0, 1),
				10
			)
			previous_cell = cell
		var start = Vector2(
			previous_cell.x * $TileMap.cell_size.x + $TileMap.cell_size.x / 2,
			previous_cell.y * $TileMap.cell_size.y + $TileMap.cell_size.y / 2
		)
		draw_line(
			start,
			$Player.position,
			Color(0, 0, 0, 1),
			4
		)

func _on_RestartButton_pressed():
	get_tree().change_scene("res://Maze.tscn")

func update_ui(player):
	var health_rate = (
		player.health_points / player.initial_health_points
	) * $CanvasLayer/CenterContainer/HBoxContainer/HealthBar.max_value
	$CanvasLayer/CenterContainer/HBoxContainer/HealthBar.value = health_rate

	var oxygen_rate = (
		player.oxygen_points / player.initial_oxygen_points
	) * $CanvasLayer/CenterContainer/HBoxContainer/OxygenBar.max_value
	$CanvasLayer/CenterContainer/HBoxContainer/OxygenBar.value = oxygen_rate

	var ammo_message = str(player.ammo) + "/" + str(player.initial_ammo)
	$CanvasLayer/CenterContainer/HBoxContainer/VBoxContainer/AmmoLabel.set_text(ammo_message)

	if player.is_recharging_ammo:
		var timer = player.get_node("RechargingTimer")
		$CanvasLayer/CenterContainer/HBoxContainer/VBoxContainer/AmmoBar.value = (
			(timer.wait_time - timer.time_left) / timer.wait_time
		) * $CanvasLayer/CenterContainer/HBoxContainer/VBoxContainer/AmmoBar.max_value
		$CanvasLayer/CenterContainer/HBoxContainer/VBoxContainer/AmmoBar.visible = true
	else:
		$CanvasLayer/CenterContainer/HBoxContainer/VBoxContainer/AmmoBar.value = 0
		$CanvasLayer/CenterContainer/HBoxContainer/VBoxContainer/AmmoBar.visible = false
