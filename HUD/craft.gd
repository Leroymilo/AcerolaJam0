extends Node2D

signal finished_crafting(tool: Globals.TOOL)

func reset():
	while $ItemList.item_count() > 1:
		$ItemList.remove_item(1)

func enable_tool(tool: Globals.TOOL, texture: Texture2D):
	var tool_name = Globals.TOOL.find_key(tool)
	$ItemList.add_item(tool_name + " x 2", texture)

func start_craft():
	visible = true

func _input(_event):
	if visible and Input.is_action_just_pressed("exit"):
		visible = false
		finished_crafting.emit(Globals.TOOL.Free)

func _on_item_list_item_selected(index: int):
	$ItemList.deselect_all()
	
	if not visible: return
	
	visible = false
	var tool_name: String = $ItemList.get_item_text(index)
	var tool = Globals.TOOL[tool_name.trim_suffix(" x 2")]
	finished_crafting.emit(tool)
