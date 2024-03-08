extends Node2D
class_name Tile

@export var type: Globals.TILE_TYPE
@export_flags("Free", "Torch", "Machete", "Ropes") var tools = 0
@export var visibility_obstruction: int = 0
@export var visibility: int = 0

var grid_pos: Vector2i
var tool_list: Array[Globals.TOOL]
var visible_from_player: bool = false

func _ready():
	for tool in Globals.TOOL.values():
		if tool & tools > 0:
			tool_list.append(tool)

func _process(_delta):
	$Fog.texture.noise.offset.z = float(Time.get_ticks_msec()) / 80

func step_on(tool: Globals.TOOL):
	return

func set_grid_pos(new_pos: Vector2i):
	grid_pos = new_pos
	position = grid_pos * 64
	$Fog.texture.noise.offset = Vector3(position.x, position.y, 0)

func make_visible():
	if visible_from_player: return
	$Fog.visible = false
	visible_from_player = true
