extends Node2D

const HEIGHT: int = 5
const WIDTH: int = 8

var rng = RandomNumberGenerator.new()

var grid: Dictionary
var max_tile_x = 0
var min_tile_x = 0
var tools: Dictionary
var game_phase

# Triggers to change phase.
# Make sure that the player is forced to go through them
var triggers: Array[Vector2i]

# Tile pools for procedural generation with weights
var pools: Array[Dictionary] = [
	{
		Globals.TILE_TYPE.forest: 8,
		Globals.TILE_TYPE.jungle: 4
	},
	{
		Globals.TILE_TYPE.forest: 5,
		Globals.TILE_TYPE.jungle: 9
	},
	{
		Globals.TILE_TYPE.forest: 3,
		Globals.TILE_TYPE.mountain_cave: 4,
		Globals.TILE_TYPE.rift: 4,
	},
]

func _ready():
	reset()

func reset():
	grid.clear()
	for tile in $Tiles.get_children():
		$Tiles.remove_child(tile)
		tile.queue_free()
	
	$Chaos.set_grid_pos(0)
	
	# reading prepared terrain :
	
	var path = "res://map_parts"
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	while true:
		var file_name = dir.get_next()
		if file_name == "":
			break
		elif !file_name.begins_with(".") and file_name.ends_with(".txt"):
			var file = FileAccess.open(path + "/" + file_name, FileAccess.READ)
			load_map_part( file.get_as_text() )
	dir.list_dir_end()
	
	# grid generation
	
	max_tile_x = 0
	min_tile_x = 0
	
	var p_pos = Vector2i(1, 2)
	$Player.set_grid_pos(p_pos)
	
	tile_explored.clear()
	show_tile(p_pos, 6)
	
	tools = {
		Globals.TOOL.Free: INF,
		Globals.TOOL.Torch: 4,
		Globals.TOOL.Machete: 0,
		Globals.TOOL.Ropes: 0
	}
	$HUD.set_tools(tools)
	
	triggers = [
		Vector2i(6, 3),
		Vector2i(48, 1)
	]
	
	game_phase = -1
	advance_phase()

func advance_phase():
	game_phase += 1
	
	if game_phase%2 == 0:
		$HUD/Dialog.start_dialog(game_phase)
	
	$Player.locked = not bool(game_phase%2)
	
	if game_phase == 2:
		tools[Globals.TOOL.Machete] += 5
		$HUD.enable_tool(Globals.TOOL.Machete)
		$HUD.set_tool(Globals.TOOL.Machete, tools[Globals.TOOL.Machete])
	
	if game_phase == 4:
		tools[Globals.TOOL.Ropes] += 6
		$HUD.enable_tool(Globals.TOOL.Ropes)
		$HUD.set_tool(Globals.TOOL.Ropes, tools[Globals.TOOL.Ropes])

func load_map_part(map_part: String):
	var lines = map_part.split('\n', false)
	var x0 = int(lines[0])
	
	for y in range(0, HEIGHT):
		var line = lines[y+1].split('\t', false)
		for i in range(line.size()):
			if Globals.TILE_TYPE.has(line[i]):
				var tile_type: Globals.TILE_TYPE = Globals.TILE_TYPE[line[i]]
				var tile = Globals.TILES_SCENES[tile_type].instantiate()
				var pos = Vector2i(x0+i, y)
				grid[pos] = tile
				tile.set_grid_pos(pos)
				$Tiles.add_child(tile)

func game_over():
	reset()

func generate_column():
	
	var pool = pools[game_phase/2]
	var cum_weights = [0]
	var values = pool.keys()
	for key in values:
		cum_weights.append(cum_weights[-1] + pool[key])
	cum_weights.pop_front()
	
	for y in range(HEIGHT):
		var grid_pos = Vector2i(max_tile_x, y)
		if grid.has(grid_pos): continue
		
		var f: float = rng.randf_range(0, cum_weights[-1])
		var i: int = 0
		while cum_weights[i] < f:
			i += 1
		
		var new_tile: Node2D = Globals.TILES_SCENES[values[i]].instantiate()
		new_tile.set_grid_pos(grid_pos)
		grid[grid_pos] = new_tile
		$Tiles.add_child(new_tile)
	
	max_tile_x += 1

func clean_back_column():
	
	if max_tile_x <= min_tile_x: return
	
	for y in range(HEIGHT):
		var key = Vector2i(min_tile_x, y)
		var tile: Node2D = grid[key]
		grid.erase(key)
		$Tiles.remove_child(tile)
		tile.queue_free()
	
	min_tile_x += 1

var tile_explored: Dictionary

func show_tile(pos: Vector2i, vision: int):
	if tile_explored.get(pos, 0) >= vision: return
	if not grid.has(pos): return
	
	grid[pos].make_visible()
	tile_explored[pos] = vision
	
	vision -= grid[pos].visibility_obstruction
	if vision <= 0: return
	
	for d in [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]:
		show_tile(pos + d, vision)

func on_player_move(new_pos: Vector2i):
	
	if 0 > new_pos.y or new_pos.y >= HEIGHT: return
	
	var pos_tools: Array[Globals.TOOL] = grid[new_pos].tool_list.duplicate()	
	
	for tool in pos_tools:
		if tools[tool] <= 0:
			pos_tools.erase(tool)
	
	if pos_tools.size() == 0:
		return
	if pos_tools.size() == 1:
		apply_player_move(pos_tools[0], new_pos)
	else:
		$Player.locked = true
		$HUD/Use.choose(pos_tools, new_pos)

func apply_player_move(tool: Globals.TOOL, new_pos: Vector2i):
	$Player.locked = false
	
	if tool == null or tools[tool] <= 0:
		return
	if tool != Globals.TOOL.Free:
		tools[tool] -= 1
		$HUD.set_tool(tool, tools[tool])
	
	var new_tile = grid[new_pos]
	
	new_tile.step_on(tool)
	print(new_pos)
	
	$Player.set_grid_pos(new_pos)
	$Chaos.count_down()
	var chaos_pos = $Chaos.grid_pos
	
	if new_pos.x <= chaos_pos:
		game_over()
		return
	
	while max_tile_x <= new_pos.x + WIDTH/2:
		generate_column()
	
	var min_chaos_pos = new_pos.x - WIDTH/2 + 1
	if chaos_pos < min_chaos_pos:
		$Chaos.set_grid_pos(min_chaos_pos)
		chaos_pos = min_chaos_pos
	
	while min_tile_x < chaos_pos:
		clean_back_column()
	
	tile_explored.clear()
	var start_vis = new_tile.visibility
	start_vis += new_tile.visibility_obstruction
	show_tile(new_pos, start_vis)
	
	if triggers.size() > 0 and triggers[0] == new_pos:
		advance_phase()
		triggers.pop_front()


func on_start_craft():
	if grid[$Player.grid_pos].type == Globals.TILE_TYPE.forest:
		$Player.locked = true
		$HUD/Craft.start_craft()

func on_end_craft(tool: Globals.TOOL):
	if tool != Globals.TOOL.Free and tools[tool] < 9:
		tools[tool] = mini(9, tools[tool] + 2)
		$HUD.set_tool(tool, tools[tool])
		$Chaos.count_down()
		$Chaos.count_down()
	
	if $Player.grid_pos.x <= $Chaos.grid_pos:
		game_over()
	
	$Player.locked = false
