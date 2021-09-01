extends Node2D

class_name BaseMaze

enum CELL_CONTENT {
	ENEMY_SPAWNER,
	OXYGEN_DUCT,
	ITEMS,
	EXIT
}

var cells = []
export var rows = 10
export var cols = 10


class Cell:
	var x
	var y
	var visited = false

	var cost = -1

	var content = null

	var up_wall = true
	var down_wall = true
	var left_wall = true
	var right_wall = true

	func _init(_x, _y):
		self.x = _x
		self.y = _y
	
	func set_cost(new_cost):
		self.cost = new_cost


func populate_cells():
	for i in range(rows):
		for j in range(cols):
			var cell = Cell.new(j, i)

			var probability = randf()
			if probability < 0.6:
				var content = CELL_CONTENT[CELL_CONTENT.keys()[randi() % len(CELL_CONTENT)]]
				cell.content = content

			cells.append(cell)
	cells[0].content = CELL_CONTENT.OXYGEN_DUCT
	cells[len(cells)-1].content = CELL_CONTENT.EXIT

func get_cell_index_from_pos(pos):
	var coords = (pos / $TileMap.cell_size.x).floor()
	return self._get_cell_index(coords.x, coords.y)


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
