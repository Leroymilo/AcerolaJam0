extends CanvasLayer

var ICONS: Dictionary
var NUMBERS: Dictionary

signal finished_dialog
signal finished_craft(tool_name: String)

func _ready():
	ICONS = {
		"Torch": $Icons/Torch,
		"Machete": $Icons/Machete,
		"Ropes": $Icons/Ropes
	}
	
	NUMBERS = {
		"Torch": $Numbers/Torch,
		"Machete": $Numbers/Machete,
		"Ropes": $Numbers/Ropes
	}

func reset():
	for name in ICONS.keys():
		ICONS[name].visible = false
		NUMBERS[name].visible = false
	ICONS["Torch"].visible = true
	NUMBERS["Torch"].visible = true
	$Craft.reset()

func enable_tool(tool_name: String):
	ICONS[tool_name].visible = true
	NUMBERS[tool_name].visible = true
	$Craft.enable_tool(tool_name, ICONS[tool_name].texture)

func set_tools(tools: Dictionary):
	for key in tools.keys():
		if key == "Free": continue
		NUMBERS[key].text = str(tools[key])

func ask_ressources(names: Array[String]) -> Dictionary:
	var result = {}
	for item_name in names:
		result[item_name] = NUMBERS[item_name].frame
	return result

func set_tool(item_name: String, qty: int):
	NUMBERS[item_name].text = str(qty)

func _on_dialog_finished_dialog():
	finished_dialog.emit()

func _on_craft_finished_crafting(tool_name):
	finished_craft.emit(tool_name)
