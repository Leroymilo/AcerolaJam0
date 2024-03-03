extends Node2D

const HEIGHT: int = 5
const WIDTH: int = 8

var rng = RandomNumberGenerator.new()
var tile_types: Dictionary
var tile_types_names: Array[String]

var grid: Dictionary
var max_tile_x = 0
var min_tile_x = 0

func _ready():
	
	# loading tile types
	
	var path = "res://tiles/tile_types"
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	while true:
		var file_name = dir.get_next()
		if file_name == "":
			#break the while loop when get_next() returns ""
			break
		elif !file_name.begins_with(".") and !file_name.ends_with(".import"):
			#if !file_name.ends_with(".import"):
			var type_name = file_name.trim_suffix(".tscn")
			tile_types_names.append(type_name)
			tile_types[type_name] = load(path + "/" + file_name)
	dir.list_dir_end()
	
	var p_pos = $Player.grid_pos
	
	while max_tile_x <= p_pos.x + WIDTH/2:
		generate_column()
	
	tile_explored.clear()
	show_tile(p_pos, 6)
	
func game_over():
	get_tree().quit()

func generate_column():
	
	for y in range(HEIGHT):
		var i: int = rng.randi_range(0, tile_types.size()-1)
		var new_tile: Node2D = tile_types[tile_types_names[i]].instantiate()
		var grid_pos = Vector2i(max_tile_x, y)
		new_tile.grid_position = grid_pos
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
	if tile_explored.get(pos, false): return
	if not grid.has(pos): return
	
	grid[pos].make_visible()
	tile_explored[pos] = true
	
	vision -= grid[pos].visibility_obstruction
	if vision <= 0: return
	
	for d in [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]:
		show_tile(pos + d, vision)

func on_player_move(new_pos: Vector2i):
	$Chaos.count_down()
	
	var chaos_pos = $Chaos.grid_pos
	
	if new_pos.x <= chaos_pos:
		game_over()
	
	while max_tile_x <= new_pos.x + WIDTH/2:
		generate_column()
	
	var min_chaos_pos = new_pos.x - WIDTH/2
	if chaos_pos < min_chaos_pos:
		$Chaos.set_grid_pos(min_chaos_pos)
		chaos_pos = min_chaos_pos
	
	while min_tile_x < chaos_pos:
		clean_back_column()
	
	tile_explored.clear()
	show_tile(new_pos, 6)

