extends Node2D

var cells = []
export var rows = 10
export var cols = 10

const Player = preload("res://Player.tscn")

class Cell:
	var x
	var y
	var visited = false

	var cost = -1

	var up_wall = true
	var down_wall = true
	var left_wall = true
	var right_wall = true

	func _init(_x, _y):
		self.x = _x
		self.y = _y

func _ready():
	randomize()
	populate_cells()
	var current_cell = cells[0]
	carve_maze(current_cell)
	fill_tilemap()

	var player = Player.instance().init(
		Vector2(64, 64),
		0,
		funcref(self, "can_move_to_pos"),
		funcref(self, "is_different_cell"),
		funcref(self, "move_to_new_cell")
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
		previous_cell.cost = -1
	if new_cell.cost == -1:
		previous_cell.cost = 1

	player.current_cell_index = cell_index
	player.move_points += new_cell.cost

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

func populate_cells():
	for i in range(rows):
		for j in range(cols):
			cells.append(Cell.new(j, i))

func carve_maze(initial_cell):
	var stack = []
	initial_cell.visited = true
	stack.append(initial_cell)
	while stack:
		var current_cell = stack.pop_back()
		var neighbors = get_unvisited_neighbors(current_cell)
		if neighbors:
			stack.append(current_cell)
			var rand_neighbor = neighbors[randi() % len(neighbors)]
			remove_wall(current_cell, rand_neighbor)
			rand_neighbor.visited = true
			stack.append(rand_neighbor)

func get_unvisited_neighbors(cell):
	var neighbors = get_neighbors(cell)
	var unvisited_neighbors = []

	for neighbor in neighbors:
		if not neighbor.visited:
			unvisited_neighbors.append(neighbor)

	return unvisited_neighbors

func get_neighbors(cell):
	var neighbors = []

	var up_neighbor_index = _get_cell_index(cell.x, cell.y - 1)
	var down_neighbor_index = _get_cell_index(cell.x, cell.y + 1)
	var left_neighbor_index = _get_cell_index(cell.x - 1, cell.y)
	var right_neighbor_index = _get_cell_index(cell.x + 1, cell.y)

	if up_neighbor_index:
		neighbors.append(cells[up_neighbor_index])
	if down_neighbor_index:
		neighbors.append(cells[down_neighbor_index])
	if left_neighbor_index:
		neighbors.append(cells[left_neighbor_index])
	if right_neighbor_index:
		neighbors.append(cells[right_neighbor_index])

	return neighbors

func _get_cell_index(x, y):
	if x < 0 or x > cols-1 or y < 0 or y > rows-1:
		return null

	return x + y * cols

func remove_wall(current, neighbor):
	var x_delta = neighbor.x - current.x
	if x_delta == 1:
		current.right_wall = false
		neighbor.left_wall = false
	elif x_delta == -1:
		current.left_wall = false
		neighbor.right_wall = false

	var y_delta = neighbor.y - current.y
	if y_delta == 1:
		current.down_wall = false
		neighbor.up_wall = false
	elif y_delta == -1:
		current.up_wall = false
		neighbor.down_wall = false


func reset_cells():
	for cell in cells:
		cell.left_wall = true
		cell.right_wall = true
		cell.up_wall = true
		cell.down_wall = true
		cell.visited = false

func _get_tile_id(cell):
	var walls = str(int(cell.up_wall)) + str(int(cell.right_wall)) + str(int(cell.down_wall)) + str(int(cell.left_wall))
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
