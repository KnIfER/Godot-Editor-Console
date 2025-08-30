@tool
extends Control
class_name ConsoleUI

@onready var input_field: TextEdit = %InputField
@onready var run_button: Button = %RunButton

const FU = preload("./FU.gd")

func _ready() -> void:
	print("run_button::", run_button)
	run_button.connect("pressed", _on_run_pressed)

var plugin : EditorPlugin

func set_plugin_reference(p):
	plugin = p

func _on_run_pressed():
	var text = input_field.text
	# print('text', text)
	
	text = text.replace(FU.space_4, "\t")

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
		

	var run_code = """@tool
extends Node
var et
var ex
func gn(n):
	return gr().get_node(n)
func gr():
	return et.get_edited_scene_root()
%s
func eval(t,x):
	et = t
	ex = x
	%s
""" % [funcs, code.replace("\n", "\n\t")]
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
 




