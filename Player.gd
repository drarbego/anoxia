extends KinematicBody2D

class_name Player

var speed = 800
var move_points = 25
var current_cell_index = null

# Maze methods
var can_move_to_pos = null
var is_different_cell = null
var move_to_new_cell = null

func init(initial_pos, cell_index, _can_move_to_pos, _is_different_cell, _move_to_new_cell):
	self.position = initial_pos
	self.current_cell_index = cell_index
	self.can_move_to_pos = _can_move_to_pos
	self.is_different_cell = _is_different_cell
	self.move_to_new_cell = _move_to_new_cell

	return self

func _physics_process(delta):
	var x = int(Input.is_key_pressed(KEY_RIGHT)) - int(Input.is_key_pressed(KEY_LEFT))
	var y = int(Input.is_key_pressed(KEY_DOWN)) - int(Input.is_key_pressed(KEY_UP))
	var dir = Vector2(x, y).normalized()
	var new_pos = self.position + dir * speed * delta
	if self.is_different_cell.call_func(new_pos, self):
		if self.can_move_to_pos.call_func(new_pos, self):
			move_and_slide(dir * speed)
			self.move_to_new_cell.call_func(new_pos, self)
	else:
		move_and_slide(dir * speed)
