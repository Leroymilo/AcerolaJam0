extends Node2D

const HEIGHT: int = 5
const WIDTH: int = 8

var rng = RandomNumberGenerator.new()
var tile_types: Dictionary
var tile_types_names: Array[String]

var grid: Dictionary
var max_tile_x = 0
var min_tile_x = 0
var available_tools = {}
var game_phase = 0

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
	$HUD.play_phase(game_phase)

func advance_phase():
	print("next phase")
	game_phase += 1
	
	if game_phase%2 == 0:
		$HUD.play_phase(game_phase)
	
	$Player.locked = not bool(game_phase%2)
	print($Player.locked)

func reset():
	grid.clear()
	for tile in $Tiles.get_children():
		$Tiles.remove_child(tile)
		tile.queue_free()
	
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
	
	var p_pos = Vector2i(1, 2)
	$Player.set_grid_pos(p_pos)
	
	while max_tile_x <= p_pos.x + WIDTH/2:
		generate_column()
	
	tile_explored.clear()
	show_tile(p_pos, 6)
	
	available_tools = {
		"Torch": 4,
		"Machete": 4,
		"Ropes": 0
	}
	$HUD.set_tools(available_tools)

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
	get_tree().quit()

func generate_column():
	
	for y in range(HEIGHT):
		var grid_pos = Vector2i(max_tile_x, y)
		if grid.has(grid_pos): continue
		
		var i: int = rng.randi_range(0, tile_types.size()-1)
		var new_tile: Node2D = tile_types[tile_types_names[i]].instantiate()
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
	
	var tools: Array[String] = grid[new_pos].get_consumables()
	
	if tools.size() > 0:
		var comp = func comp(t_a, t_b):
			return available_tools[t_a] > available_tools[t_b]
		tools.sort_custom(comp)
	
		if not $HUD.use_tool(tools[0]):
			return
	
	$Player.set_grid_pos(new_pos)
	
	$Chaos.count_down()
	
	var chaos_pos = $Chaos.grid_pos
	
	if new_pos.x <= chaos_pos:
		game_over()
	
	while max_tile_x <= new_pos.x + WIDTH/2:
		generate_column()
	
	var min_chaos_pos = new_pos.x - WIDTH/2 + 1
	if chaos_pos < min_chaos_pos:
		$Chaos.set_grid_pos(min_chaos_pos)
		chaos_pos = min_chaos_pos
	
	while min_tile_x < chaos_pos:
		clean_back_column()
	
	tile_explored.clear()
	show_tile(new_pos, 6)
