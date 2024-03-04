extends Node2D

var playing_dialog: bool = false
var text_scrolling: bool = false
var FACES: Dictionary
var dialog: PackedStringArray = []
var line_index: int = 0
var dialog_line: String = ""
var char_index: int = 0

signal finished_dialog

func _ready():
	
	# loading faces
	
	var path = "res://HUD/faces"
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	while true:
		var file_name = dir.get_next()
		if file_name == "":
			break
		elif !file_name.begins_with(".") and file_name.ends_with(".png"):
			var face_name = file_name.trim_suffix(".png")
			FACES[face_name] = load(path + "/" + face_name + ".png")
	dir.list_dir_end()

func start_dialog(phase: int):
	var file_path = "res://HUD/dialog/phase_" + str(phase).lpad(2, "0") + ".txt"
	var file = FileAccess.open(file_path, FileAccess.READ)
	dialog = file.get_as_text().split('\n', false)
	line_index = -1
	playing_dialog = true
	visible = true
	next_line()

func start_text_scroll():
	$TextArrow.visible = false
	$Text.text = ""
	text_scrolling = true
	$TextTimer.start()

func scroll_text():
	char_index += 1
	$Text.text = dialog_line.substr(0, char_index)
	if char_index >= dialog_line.length():
		end_text_scroll()

func end_text_scroll():
	text_scrolling = false
	$Text.text = dialog_line
	$TextArrow.visible = true
	$TextTimer.stop()

func next_line():
	line_index += 1
	char_index = 0
	if line_index >= dialog.size():
		end_dialog()
		return
	
	var line = dialog[line_index].split(' : ', false, 1)
	var face_name = line[0]
	dialog_line = line[1]
	
	$Portrait.texture = FACES[face_name]
	
	start_text_scroll()

func end_dialog():
	playing_dialog = false
	visible = false
	finished_dialog.emit()

func _input(_event):
	if playing_dialog:
		if Input.is_action_just_pressed("ui_accept"):
			if text_scrolling:
				end_text_scroll()
			else:
				next_line()
