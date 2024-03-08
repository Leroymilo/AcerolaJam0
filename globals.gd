extends Node

# constants:

const TOOL_NAMES: Array[String] = ["Free", "Torch", "Machete", "Ropes"]
enum TOOL {
	None = 0,
	Free = 1,
	Torch = 2,
	Machete = 4,
	Ropes = 8,
}

enum TILE_TYPE {
	forest = 1,
	elf_village = 2,
	jungle = 4,
	mountain_cave = 8,
	peak = 16,
	rift = 32
}

const TILES_SCENES: Dictionary = {
	TILE_TYPE.forest: preload("res://tiles/tile_types/forest.tscn"),
	TILE_TYPE.elf_village: preload("res://tiles/tile_types/elf_village.tscn"),
	TILE_TYPE.jungle: preload("res://tiles/tile_types/jungle.tscn"),
	TILE_TYPE.mountain_cave: preload("res://tiles/tile_types/mountain_cave.tscn"),
	TILE_TYPE.peak: preload("res://tiles/tile_types/peak.tscn"),
	TILE_TYPE.rift: preload("res://tiles/tile_types/rift.tscn"),
}
