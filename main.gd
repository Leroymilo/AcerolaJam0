extends Node2D

const HEIGHT: int = 5
const WIDTH: int = 8

var rng = RandomNumberGenerator.new()
var tile_types: Dictionary
var tile_types_names: Array[String]

var grid: Dictionary
var max_tile_x = 0
var min_tile_x = 0
var tools
var game_phase

# Triggers to change phase.
# Make sure that the player is forced to go through them
var triggers: Array[Vector2i] = [
	Vector2i(6, 3)
]

# Tile pools for procedural generation with weights
var pools: Array[Dictionary] = [
	{
		"forest": 1
	},
	{
		"forest": 8,
		"jungle": 5
	},
	{
		"forest": 1
	},
	{
		"forest": 7,
		"jungle": 9
	}
]

func _ready():
	
	# loading tile types
	
	var path = "res://tiles/tile_types"
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	while true:
		var file_name = dir.get_next()
		if file_name == "":
			break
		elif !file_name.begins_with(".") and file_name.ends_with(".tscn"):
			var type_name = file_name.trim_suffix(".tscn")
			tile_types_names.append(type_name)
			tile_types[type_name] = load(path + "/" + file_name)
	dir.list_dir_end()
	
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
		"Free": INF,
		"Torch": 4,
		"Machete": 0,
		"Ropes": 0
	}
	$HUD.set_tools(tools)
	
	game_phase = -1
	advance_phase()

func advance_phase():
	game_phase += 1
	
	if game_phase%2 == 0:
		$HUD/Dialog.start_dialog(game_phase)
	
	$Player.locked = not bool(game_phase%2)
	
	if game_phase == 2:
		tools["Machete"] += 5
		$HUD.enable_tool("Machete")
		$HUD.set_tool("Machete", tools["Machete"])

func load_map_part(map_part: String):
	var lines = map_part.split('\n', false)
	var x0 = int(lines[0])
	
	for y in range(0, HEIGHT):
		var line = lines[y+1].split('\t', false)
		for i in range(line.size()):
			if tile_types.has(line[i]):
				var tile = tile_types[line[i]].instantiate()
				var pos = Vector2i(x0+i, y)
				grid[pos] = tile
				tile.set_grid_pos(pos)
				$Tiles.add_child(tile)

func game_over():
	reset()

func generate_column():
	
	var pool = pools[game_phase]
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
		
		var new_tile: Node2D = tile_types[values[i]].instantiate()
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
	
	var pos_tools: Array[String] = grid[new_pos].get_consumables()
	var tool: String
	
	if pos_tools.size() > 0:
		var comp = func comp(t_a, t_b):
			return tools[t_a] > tools[t_b]
		pos_tools.sort_custom(comp)
		tool = pos_tools[0]
	
		if tools[tool] <= 0:
			return
		if tool != "Free":
			tools[tool] -= 1
			$HUD.set_tool(tool, tools[tool])
	else: return
	
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
	var start_vis = grid[new_pos].get_visibility(tool)
	start_vis += grid[new_pos].visibility_obstruction
	show_tile(new_pos, start_vis)
	
	if triggers.size() > 0 and triggers[0] == new_pos:
		advance_phase()
		triggers.pop_front()

func on_start_craft():
	if grid[$Player.grid_pos].type_name == "forest":
		$Player.locked = true
		$HUD/Craft.start_craft()

func on_end_craft(tool_name: String):
	if tool_name != "null" and tools[tool_name] < 9:
		tools[tool_name] = mini(9, tools[tool_name] + 2)
		$HUD.set_tool(tool_name, tools[tool_name])
		$Chaos.count_down()
		$Chaos.count_down()
	
	if $Player.grid_pos.x <= $Chaos.grid_pos:
		game_over()
	
	$Player.locked = false
