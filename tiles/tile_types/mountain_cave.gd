extends Tile

func step_on(tool: Globals.TOOL):
	if tool == Globals.TOOL.Ropes:
		$Ropes.visible = true
		tools = Globals.TOOL.Free
		tool_list = [Globals.TOOL.Free]
		visibility = 8
