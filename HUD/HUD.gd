extends CanvasLayer

var ICONS: Dictionary
var NUMBERS: Dictionary

signal finished_dialog

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

func set_tools(tools: Dictionary):
	for key in tools.keys():
		NUMBERS[key].text = str(tools[key])

func ask_ressources(names: Array[String]) -> Dictionary:
	var result = {}
	for item_name in names:
		result[item_name] = NUMBERS[item_name].frame
	return result

func use_tool(item_name: String) -> bool:
	if NUMBERS[item_name].text == "0":
		return false
	
	NUMBERS[item_name].text = str(int(NUMBERS[item_name].text) - 1)
	return true

func play_phase(phase: int):
	$Dialog.start_dialog(phase)

func _on_dialog_finished_dialog():
	finished_dialog.emit()
