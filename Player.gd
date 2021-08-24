extends KinematicBody2D

class_name Player

const Bullet = preload("res://Bullet.tscn")

var speed = 800
var move_points = 15
var current_cell_index = null

# Maze methods
var can_move_to_pos = null
var is_different_cell = null
var move_to_new_cell = null
var get_cell_at = null

func init(
	initial_pos,
	cell_index,
	_can_move_to_pos,
	_is_different_cell,
	_move_to_new_cell,
	_get_cell_at
	):
	self.position = initial_pos
	self.current_cell_index = cell_index
	self.can_move_to_pos = _can_move_to_pos
	self.is_different_cell = _is_different_cell
	self.move_to_new_cell = _move_to_new_cell
	self.get_cell_at = _get_cell_at

	return self

func _process(delta):
	var mouse_dir = (get_global_mouse_position() - self.position).normalized() * 64
	$Gun.position = mouse_dir
	$Gun.rotation = mouse_dir.angle()
	$Gun.flip_v = mouse_dir.x < 0

func _unhandled_input(event):
	if event.is_action_released("shoot"):
		add_child(
			Bullet.instance().init(
				$Gun.position,
				(get_global_mouse_position() - self.position).normalized()
			)
		)
	if event.is_action_pressed("do_action"):
		var current_cell = self.get_cell_at.call_func(self.current_cell_index)
		# TODO use enum
		# TODO refactor this shit
		if current_cell.content == 1:
			var cells = get_node('..').cells
			for cell in cells:
				cell.cost = -1
			self.move_points = 15


func _physics_process(delta):
	var x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	var y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	var dir = Vector2(x, y).normalized()
	var new_pos = self.position + dir * speed * delta
	if self.is_different_cell.call_func(new_pos, self):
		if self.can_move_to_pos.call_func(new_pos, self):
			move_and_slide(dir * speed)
			self.move_to_new_cell.call_func(new_pos, self)
	else:
		move_and_slide(dir * speed)
