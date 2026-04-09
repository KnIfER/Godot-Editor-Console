@tool
extends Control
class_name ConsoleUI

@onready var input_field: TextEdit = %InputField


const FU = preload("./FU.gd")

var lastRun := 0

func _input(event):
#	if event is InputEventKey and not event.pressed:
#		if event.ctrl_pressed and event.shift_pressed and event.keycode == KEY_F13 or event.keycode == KEY_F12:
#			run_clipboard()
		
	if  DDD.auto_runs.size()>1 and Input.is_action_just_pressed("auto_run") && FU.debug() \
		and Time.get_ticks_msec() - lastRun>250 \
		and not DDD.auto_running:
		lastRun = Time.get_ticks_msec()
		for node in DDD.auto_runs:
			if node is AutoUpdate:
				node.do_run()
			
	if input_field.has_focus():
		if not plugin.ddd_set:
			var ddd = FU.ddd(self)
			if ddd!=null:
				ddd.plugin = self
				plugin.ddd_set=true
		if event is InputEventKey and not event.pressed:
			if Time.get_ticks_msec() - lastRun>250:
				lastRun = Time.get_ticks_msec()
				if event.ctrl_pressed and event.shift_pressed and event.keycode == KEY_ENTER: # and event.pressed
					_on_edit_pressed()
					_on_run_pressed()
					accept_event()
					lastRun = Time.get_ticks_msec()
				elif event.ctrl_pressed and event.keycode == KEY_ENTER: # and event.pressed
					_on_run_pressed()
					accept_event()
					lastRun = Time.get_ticks_msec()


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
	
var script_items :Array[UserScript]= []

class UserScript:
	var filename
	var display
	var category
	var content
	var clazz
	var full_path
	var args_c
	func _init(fn):
		filename = fn
		display = FU.nosuffix(fn).replace("_", " ")

func scan_found_script(file_name, full_path):
	var item :UserScript= null
	if file_name.ends_with(".gd"):
		if file_name.find("snippets")>=0: # load class
			var clazz = load(full_path).new()
			# clazz = load(full_path).new()
			# script_instance_cache[file_name] = clazz
			# printt("clazz::", clazz)
			var methods = clazz.get_method_list()
			for met in methods:
				if met.name.begins_with("__"):
					item = UserScript.new(met.name.substr(2))
					# printt("item::", met.name)
					item.args_c = met.args.size()
					item.clazz = clazz
					item.full_path = full_path
					script_items.push_back(item)
					item = null
				item = UserScript.new("")
				item.display = "Open :: "+file_name
				item.full_path = full_path
				item.category = 3
	# 	else: # record class
	# 		item = UserScript.new(file_name)
	# 		item.full_path = full_path
	# 		item.category = 1
			
	# elif file_name.ends_with(".gd.txt"): # record text
	# 	item = UserScript.new(file_name)
	# 	item.full_path = full_path
	# 	item.category = 2
	if item:
		script_items.push_back(item)
	
func scan_userscripts_directory(dir_path):
	var dir = DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir():
				var full_path = dir_path + "/" + file_name
				scan_found_script(file_name, full_path)
				
			file_name = dir.get_next()
		
		dir.list_dir_end()
	else:
		print("无法打开目录: ", dir_path)


func _on_edit_pressed():
	# plugin.get_editor_interface().edit_resource(load("res://addons/console_input/Runner.gd"))
	show_dynamic_menu()

func invoke_gd_file(full_path, method_name):
	printt("invoke_gd_file::", full_path, method_name)
	var clazz = load(full_path).new()
	var methods = clazz.get_method_list()
	for met in methods:
		if met.name==method_name:
			printt("method_name::", method_name)
			var args_c = met.args.size()
			return run_clazz_method(clazz, full_path, method_name, args_c)
	printt("找不到 method_name::", method_name)
			

func run_clazz_method(clazz, full_path, method_name, args_c):
	var args = []
	if args_c>0:
		args.push_back(plugin.get_editor_interface())
	if args_c>1:
		args.push_back(plugin)
	if args_c>2:
		var data = FU.get_or_add(plugin.script_data, full_path, {})
		args.push_back(data)
	return clazz.callv(method_name, args)
			

var script_instance_cache := {}
func _on_use_menu(id: int):
	var item := script_items[id-1]
	# printt("use_menu::", item.filename)
	if item.category==3: # open and eidt source file
		plugin.get_editor_interface().edit_resource(load(item.full_path))
	elif item.clazz:
		var ret = run_clazz_method(item.clazz, item.full_path, "__"+item.filename, item.args_c)
		if typeof(ret)==TYPE_STRING:
			eval_string(ret)
	if !plugin.keepMenuOpen:
		popup_menu.queue_free()
		script_items = []
	plugin.keepMenuOpen = false

var popup_menu:PopupMenu
func show_dynamic_menu():
	plugin.keepMenuOpen = false
	script_items = []
	scan_found_script("snippets.gd", "res://addons/console_input/snippets.gd")
	script_items.push_back(null)
	scan_userscripts_directory("res://addons/console_input/userscripts/")
	script_items.push_back(null)
	
	var seps_cnt = 2
	var pos: Vector2 = %EditButton.global_position-Vector2(0,(script_items.size()-2)*31+7*2)
	var popup := PopupMenu.new()
	popup.hide_on_item_selection = false
	var cc=0
	for fn in script_items:
		cc+=1
		if fn==null:
			popup.add_separator()
		else:
			popup.add_item(fn.display, cc)
	popup.id_pressed.connect(_on_use_menu)
	popup_menu = popup

	# 弹出菜单
	add_child(popup)
	popup.position = pos
	popup.popup()
	

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
	if "" == text: # Runner.gd
		text = FU.read_all("res://addons/console_input/Runner.gd")
	# print('text', text)
	var ret = eval_string(text)
	print("ret:: ", ret)
		
func eval_string(text):
	# printt("eval_string::", text)
	var run_code
	if "func eval" in text: # as-is
		run_code = text
	elif text.find(".gd::")>0:
		var parts = text.split("\n")[0].split("::")
		return invoke_gd_file(parts[0], parts[1]) # script_path, method_name
	else: # separate
		text = process_text(text)
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
	# if err:
	# 	print("err::", err, run_code)
	# print("err::", err, run_code)


	%Runner.set_script(script)
	var ret = %Runner.eval(plugin.get_editor_interface(), plugin)
	# printt("ret ??? ::", ret, run_code)
	script.set_source_code("")
	return ret
 
