extends Node2D

var pos: Vector2i

signal chose(tool: Globals.TOOL, new_pos: Vector2i)

func start_use(tools: Array[Globals.TOOL], new_pos: Vector2i):
	$ItemList.clear()
	for tool in tools:
		var tool_name = Globals.TOOL.find_key(tool)
		$ItemList.add_item(tool_name)

	visible = true
	$ItemList.grab_focus()
	$ItemList.select(0)
	
	pos = new_pos

func _input(_event):
	if visible and Input.is_action_just_pressed("exit"):
		visible = false
		chose.emit(Globals.TOOL.None, pos)
	elif visible and Input.is_action_just_pressed("select"):
		var index = $ItemList.get_selected_items()[0]
		choose(index)

func choose(index, _pos=null, mouse=null):
	if mouse != 1 and mouse != null: return
	visible = false
	var tool_name: String = $ItemList.get_item_text(index)
	var tool = Globals.TOOL[tool_name]
	chose.emit(tool, pos)

