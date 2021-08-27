extends KinematicBody2D

class_name Player

export var speed = 800
export var initial_move_points = 5
var move_points = initial_move_points

# Main player state
var current_cell_index = null
var is_cooled_down = true

var maze = null

onready var current_state = $States/Attached


func init(
	initial_pos,
	cell_index,
	_maze
	):
	self.position = initial_pos
	self.current_cell_index = cell_index
	self.maze = _maze

	return self

func set_state(new_state):
	if (new_state == $States/Attached):
		var current_cell = self.maze.get_cell_at(self.current_cell_index)
		if current_cell.content == 1: # HEY >:( USE ENUMS, WTF DOES THE 1 MEAN??
			for cell in self.maze.cells:
				cell.set_cost(-1)
			self.move_points = self.initial_move_points - 1
			self.maze.move_to_new_cell(self.position, self)

			self.current_state = new_state
			self.current_state.ready(self)
	if (new_state == $States/Detached):
		self.current_state = new_state
		self.current_state.ready(self)

func _handle_shooting():
	if is_cooled_down:
		self.maze.spawn_bullet(self)
		is_cooled_down = false
		$CooldownTimer.start()

func _process(_delta):
	var mouse_dir = (get_global_mouse_position() - self.position).normalized() * 64
	$Gun.position = mouse_dir
	$Gun.rotation = mouse_dir.angle()
	$Gun.flip_v = mouse_dir.x < 0

func _unhandled_input(event):
	if event.is_action_released("shoot"):
		self._handle_shooting()
	if event.is_action_pressed("do_action"):
		self.set_state($States/Attached)
	if event.is_action_pressed("release"):
		self.set_state($States/Detached)

func _on_CooldownTimer_timeout():
	self.is_cooled_down = true

func _physics_process(delta):
	if self.current_state:
		self.current_state.physics_process(delta, self)
