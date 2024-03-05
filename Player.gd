extends Node2D

var grid_pos = Vector2i(1, 2)
var locked = true

signal try_move(new_pos: Vector2i)
signal try_craft()

func set_grid_pos(new_pos):
	grid_pos = new_pos
	position = 64 * grid_pos + Vector2i(32, 32)

func _input(_event):
	if locked: return
	
	if Input.is_action_just_released("craft"):
		try_craft.emit()
		return
	
	var dir = Vector2i(Input.get_vector("left", "right", "up", "down"))
	if dir == Vector2i(0, 0): return
	
	try_move.emit(grid_pos + dir)
