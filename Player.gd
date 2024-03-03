extends Node2D

var grid_pos = Vector2i(1, 2)

signal try_move(new_pos: Vector2i)

func set_grid_pos(new_pos):
	grid_pos = new_pos
	position = 64 * grid_pos + Vector2i(32, 32)

func _input(_event):
	var dir = Vector2i(Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down"))
	if dir == Vector2i(0, 0): return
	
	try_move.emit(grid_pos + dir)
