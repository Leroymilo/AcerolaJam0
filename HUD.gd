extends CanvasLayer

var ICONS: Dictionary
var NUMBERS: Dictionary

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

func ask_ressources(names: Array[String]) -> Dictionary:
	var result = {}
	for item_name in names:
		result[item_name] = NUMBERS[item_name].frame
	return result

func use(item_name: String) -> bool:
	if NUMBERS[item_name].frame == 0:
		return false
	
	NUMBERS[item_name].frame -= 1
	return true
