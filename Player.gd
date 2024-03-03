extends Node2D

var grid_pos = Vector2i(1, 2)

signal moved(new_pos: Vector2i)

func _process(delta):
	position = 64 * grid_pos + Vector2i(32, 32)

func _input(event):
	var dir = Vector2i(Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down"))
	if dir == Vector2i(0, 0): return
	
	grid_pos += dir
	moved.emit(grid_pos)
