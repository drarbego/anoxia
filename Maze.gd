extends Node2D

const TILE_SIZE = 64
var cells = []
export var rows = 8
export var cols = 8


class Cell:
	var x
	var y
	var square_tiles = 3
	var size = square_tiles * TILE_SIZE
	var visited = false

	var up_wall = true
	var down_wall = true
	var left_wall = true
	var right_wall = true

	func _init(_x, _y):
		self.x = _x
		self.y = _y

	func get_rect():
		return Rect2(
			Vector2(self.x*self.size, self.y*self.size),
			Vector2(self.size, self.size)
		)

	func get_top_left_xy():
		return Vector2(self.x * square_tiles, self.y * square_tiles)

	func get_bottom_right_xy():
		return Vector2((self.x+1) * square_tiles, (self.y+1)*square_tiles)

func _ready():
	randomize()
	populate_cells()
	var current_cell = cells[0]
	carve_maze(current_cell)
	fill_tilemap()

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


func _unhandled_input(event):
	if event.is_action_released("refresh"):
		reset_cells()
		carve_maze(cells[0])
		fill_tilemap()

func reset_cells():
	for cell in cells:
		cell.left_wall = true
		cell.right_wall = true
		cell.up_wall = true
		cell.down_wall = true
		cell.visited = false

func fill_tilemap():
	for cell in cells:
		var tl = cell.get_top_left_xy()
		var br = cell.get_bottom_right_xy()
		var local_x = 0
		var local_y = 0
		for x in range(tl.x, br.x):
			local_y = 0
			for y in range(tl.y, br.y):
				var tile_id = -1
				if cell.up_wall and local_y == 0:
					tile_id = 0
				if cell.down_wall and local_y == cell.square_tiles-1:
					tile_id = 0
				if cell.right_wall and local_x == cell.square_tiles-1:
					tile_id = 0
				if cell.left_wall and local_x == 0:
					tile_id = 0
				$TileMap.set_cell(x, y, tile_id)
				local_y += 1
			local_x += 1
