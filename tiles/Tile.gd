extends Node2D

@export_flags("Torch", "Machete", "Ropes") var consumes
@export var visibility_obstruction: int

var grid_position: Vector2i = Vector2i(0, 0)
var visible_from_player: bool = false

func _process(delta):
	position = grid_position * 64

func make_visible():
	if visible_from_player: return
	$Fog.visible = false
	visible_from_player = true
