extends CanvasLayer

var ICONS: Dictionary
var NUMBERS: Dictionary

signal finished_dialog
signal finished_craft(tool: Globals.TOOL)
signal chose(tool: Globals.TOOL, new_tile: Vector2i)

func _ready():
	ICONS = {
		Globals.TOOL.Torch: $Icons/Torch,
		Globals.TOOL.Machete: $Icons/Machete,
		Globals.TOOL.Ropes: $Icons/Ropes
	}
	
	NUMBERS = {
		Globals.TOOL.Torch: $Numbers/Torch,
		Globals.TOOL.Machete: $Numbers/Machete,
		Globals.TOOL.Ropes: $Numbers/Ropes
	}

func reset():
	for tool_name in ICONS.keys():
		ICONS[tool_name].visible = false
		NUMBERS[tool_name].visible = false
	ICONS[Globals.TOOL.Torch].visible = true
	NUMBERS[Globals.TOOL.Torch].visible = true
	$Craft.reset()

func enable_tool(tool: Globals.TOOL):
	ICONS[tool].visible = true
	NUMBERS[tool].visible = true
	$Craft.enable_tool(tool, ICONS[tool].texture)

func set_tools(tools: Dictionary):
	for key in tools.keys():
		if key == Globals.TOOL.Free: continue
		NUMBERS[key].text = str(tools[key])

func set_tool(tool: Globals.TOOL, qty: int):
	NUMBERS[tool].text = str(qty)

func _on_dialog_finished_dialog():
	finished_dialog.emit()

func _on_craft_finished_crafting(tool: Globals.TOOL):
	finished_craft.emit(tool)

func _on_use_chose(tool, pos):
	chose.emit(tool, pos)
