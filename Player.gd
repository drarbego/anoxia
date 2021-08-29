extends KinematicBody2D

class_name Player

export var initial_speed = 400
var speed = initial_speed
export var initial_move_points = 5
var move_points = initial_move_points
export var initial_health_points = 50.0
var health_points = initial_health_points
export var initial_oxygen_points = 50.0
var oxygen_points = initial_oxygen_points

# Main player state
var current_cell_index = null
var is_cooled_down = true
var hit_back_dir = Vector2.ZERO
var game_over = false

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
	if new_state == $States/Attached:
		var current_cell = self.maze.get_cell_at(self.current_cell_index)
		if current_cell.content == 1: # HEY >:( USE ENUMS, WTF DOES THE 1 MEAN??
			for cell in self.maze.cells:
				cell.set_cost(-1)
			self.move_points = self.initial_move_points - 1
			self.maze.move_to_new_cell(self.position, self)

			self.current_state = new_state
			self.current_state.ready(self)
	if new_state == $States/Detached:
		self.current_state = new_state
		self.current_state.ready(self)

func _handle_shooting():
	if self.game_over:
		return

	if self.is_cooled_down:
		self.maze.spawn_bullet(self)
		is_cooled_down = false
		$CooldownTimer.start()

func _process(_delta):
	if self.game_over:
		return

	var mouse_dir = (get_global_mouse_position() - self.position).normalized() * 64
	$Gun.position = mouse_dir
	$Gun.rotation = mouse_dir.angle()
	$Gun.flip_v = mouse_dir.x < 0

	var origin = get_global_transform_with_canvas().origin
	var normalized_pos = Vector2(
		origin.x / get_viewport_rect().size.x,
		origin.y / get_viewport_rect().size.y
	)
	$Camera2D/CanvasLayer/ColorRect.material.set_shader_param("player_pos", normalized_pos)

func _input(event):
	if event.is_action_released("shoot"):
		self._handle_shooting()
	if event.is_action_pressed("do_action"):
		self.set_state($States/Attached)
	if event.is_action_pressed("release"):
		self.set_state($States/Detached)

func _on_CooldownTimer_timeout():
	self.is_cooled_down = true

func _physics_process(delta):
	if self.game_over:
		return
	if self.current_state:
		self.current_state.physics_process(delta, self)

func get_dir():
	if self.hit_back_dir != Vector2.ZERO:
		return self.hit_back_dir

	var x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	var y = int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	return Vector2(x, y).normalized()

func get_speed():
	if self.hit_back_dir != Vector2.ZERO:
		return self.speed * 2

	return self.speed

func receive_attack(dir, damage):
	self.health_points -= damage
	self.hit_back_dir = dir
	if self.health_points <= 0:
		self.set_game_over(true)
	$HitBackTimer.start()
	self.update_ui()

func _on_HitBackTimer_timeout():
	self.hit_back_dir = Vector2.ZERO

func update_ui():
	self.maze.update_ui(self)

func set_game_over(is_game_over):
	self.game_over = is_game_over
	maze.get_node("CanvasLayer/GameOverOptions").visible = is_game_over
