extends KinematicBody2D

class_name Player

var TILE_SIZE = 128

var speed = 800

func _physics_process(delta):
	var x = int(Input.is_key_pressed(KEY_RIGHT)) - int(Input.is_key_pressed(KEY_LEFT))
	var y = int(Input.is_key_pressed(KEY_DOWN)) - int(Input.is_key_pressed(KEY_UP))
	var dir = Vector2(x, y).normalized()

	move_and_slide(dir * speed)
