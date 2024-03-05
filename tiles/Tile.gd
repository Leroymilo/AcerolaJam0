extends Node2D

@export var type_name: String
@export var visibility_obstruction: int = 0
@export var visibilities: Dictionary = {}

const CONSUMABLES: Dictionary = {
	1: "Free",
	2: "Torch",
	4: "Machete",
	8: "Ropes"
}

var grid_pos: Vector2i
var visible_from_player: bool = false

func _process(_delta):
	$Fog.texture.noise.offset.z = float(Time.get_ticks_msec()) / 80

func get_consumables() -> Array[String]:
	var result: Array[String]
	result.assign(visibilities.keys())
	return result

func get_visibility(tool: String):
	return visibilities[tool]

func set_grid_pos(new_pos: Vector2i):
	grid_pos = new_pos
	position = grid_pos * 64
	$Fog.texture.noise.offset = Vector3(position.x, position.y, 0)

func make_visible():
	if visible_from_player: return
	$Fog.visible = false
	visible_from_player = true
