@tool
extends Control
class_name ConsoleUI

@onready var input_field: TextEdit = %InputField


const FU = preload("./FU.gd")

func _input(event):
#	if event is InputEventKey and not event.pressed:
#		if event.ctrl_pressed and event.shift_pressed and event.keycode == KEY_F13 or event.keycode == KEY_F12:
#			run_clipboard()
	if input_field.has_focus():
		if event is InputEventKey and not event.pressed:
			if event.ctrl_pressed and event.shift_pressed and event.keycode == KEY_ENTER: # and event.pressed
				_on_edit_pressed()
				_on_run_pressed()
				accept_event()
			elif event.ctrl_pressed and event.keycode == KEY_ENTER: # and event.pressed
				_on_run_pressed()
				accept_event()


func _ready() -> void:
	%RunButton.connect("pressed", _on_run_pressed)
	%EditButton.connect("pressed", _on_edit_pressed)


func run_clipboard() -> void:
	input_field.text = FU.getTmpText()
	_on_run_pressed()


var plugin : EditorPlugin

func set_plugin_reference(p):
	plugin = p
	
var _re_dd_
var _re_pp_
var _re_dd_1
var _re_pp_1
func replace_dd_pattern(input, d=true):
	# (?<!\S)	 dd\(	 (?!\s*\[)  
	if not _re_dd_:
		_re_dd_ = RegEx.new()
		_re_pp_ = RegEx.new()
		const pattern = "(?<!\\S)dd\\((?!\\s*\\[)(.*?)\\)";
		_re_dd_.compile(pattern)
		_re_pp_.compile(pattern.replace("dd", "pp"))
	var result = input
	var matches = (_re_dd_ if d else _re_pp_).search_all(result)
	var reprefix = "dd([" if d else "pp(["
	for match in matches:
		var full_match = match.get_string()
		var inner_content = match.get_string(1)
		var replacement = reprefix + inner_content + "])"
		result = result.replace(full_match, replacement)
	return result
func replace_dd_macro(input, d=true):
	# (?<!\S)	 dd,	 (?!\s*\[)  
	if not _re_dd_1:
		_re_dd_1 = RegEx.new()
		_re_pp_1 = RegEx.new()
		const pattern = "(?<!\\S)dd[, ](.*)";
		_re_dd_1.compile(pattern)
		_re_pp_1.compile(pattern.replace("dd", "pp"))
	var result = input
	var matches = (_re_dd_1 if d else _re_pp_1).search_all(result)
	var reprefix = "dd([" if d else "pp(["
	for match in matches:
		var full_match = match.get_string()
		var inner_content = match.get_string(1)
		var replacement =  reprefix + inner_content + "])"
		result = result.replace(full_match, replacement)
	return result
	
func _on_edit_pressed():
	plugin.get_editor_interface().edit_resource(load("res://addons/console_input/Runner.gd"))

#func _on_edit_pressed_ret():
#	var url = 'http://127.0.0.1:8080/DB.jsp?bat=D:/Code/FigureOut/chrome/extesions/AutoHotKey/gd_clear.ahk'
#	if not http_request:
#		http_request = HTTPRequest.new()
#		add_child(http_request)
#	http_request.request_completed.connect(_on_request_completed)
#	http_request.request(url)
#
#func _on_request_completed(result, response_code, headers, body):
#	print("_on_request_completed")
#	http_request.request_completed.disconnect(_on_request_completed)
#	_on_run_pressed()

func process_text(text):
	text = text.replace(FU.space_4, "\t")
	text = replace_dd_pattern(text)
	text = replace_dd_pattern(text, false)
	text = replace_dd_macro(text)
	text = replace_dd_macro(text, false)
	return text
	
func _on_run_pressed():
	# printt('text', %EditButton.button_pressed)
	var text = input_field.text
	text = process_text(text)
	# print('text', text)
	var run_code
	if "" == text: # Runner.gd
		run_code = FU.read_all("res://addons/console_input/Runner.gd")
	elif "func eval" in text: # as-is
		run_code = text
	else: # separate
		var end_pos = text.length() 
		var funcs = ""
		var code = text
		var lastLine = 0
		while end_pos - 1>=0:
			var newline_pos = text.rfind("\n", end_pos - 1)
			if newline_pos == -1:
				break
			# var line = text.substr(newline_pos + 1, end_pos - newline_pos)
			var idx = newline_pos+1
			if( FU.StrStartsWith(text, "\t", idx) 
					or FU.StrStartsWith(text, "	", idx) ) :
				if not FU.StrEmpty(text, idx, end_pos):
					if "func " in text:
						funcs = text.substr(0, end_pos)
						lastLine -= end_pos
						code = text.substr(end_pos)
					break
			elif lastLine==0 and not FU.StrEmpty(text, idx, end_pos):
				lastLine = idx
			end_pos = newline_pos
		
		# add return to the last line
		if lastLine>=0 and FU.StrStartsWith(code, "=", lastLine):
			code = code.substr(0, lastLine) + "return " + code.substr(lastLine+1)
			
		# if(!FU.StrEmpty(code, 0, 1)):
		if(code.begins_with("\t")):
			code = code.substr(1)
		else:
			code = code.replace("\n", "\n\t")
			
		run_code = """@tool
extends Node
var _et_ # : EditorInterface
var _ex_ # : EditorPlugin
func sn(idx=0):
	return sns()[idx]
func sns():
	return _et_.get_selection().get_selected_nodes()

func gn(n):
	return gr().get_node(n)
func gr():
	return _et_.get_edited_scene_root()

func dd(args):
	print(str_(args))
func pp(args):
	DDD.set_text(str_(args))
func str_(args):
	if len(args)==1:
		args = args[0]
	return str(args)

	
func kn():
	var n = sn()
	if n:
		n.process_mode = 4 if n.process_mode!=4 else 0

# start
%s
func eval(e,x):
	_et_ = e
	_ex_ = x
	%s
""" % [funcs, code]

	var script = GDScript.new()
	script.set_source_code(run_code)
	var err = script.reload()
	if err:
		print("err::", err, run_code)
	# print("err::", err, run_code)


	%Runner.set_script(script)
	var ret = %Runner.eval(plugin.get_editor_interface(), plugin)
	script.set_source_code("")
	print("ret:: ", ret)
 
