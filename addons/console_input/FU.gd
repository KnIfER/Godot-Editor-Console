
extends Node
class_name FU


static func rpath(ref, relative_path):
	var script_path = ref.get_script().get_path()
	var script_dir = script_path.get_base_dir() 
	return script_dir + "/" + relative_path


static func exists(path) :
	return ResourceLoader.exists(path)


static func CharEmpty(ch):
	return ch == " " or ch == "\t" or ch == "\n" or ch == "\r"
	
static func StrEmpty(text: String, from:int=0, to:int=-1):
	if to==-1:
		to = text.length()
	var start = max(0, from)
	var end = min(text.length(), to)
	if start >= end:
		return true
	for i in range(start, end):
		if not CharEmpty(text[i]):
			return false
	return true
	
static func StrStartsWith(text: String, prefix: String, offset: int):
	if offset < 0 or offset > text.length():
		return false
	if prefix.is_empty():
		return true
	if (text.length() - offset) < prefix.length():
		return false
	# 逐字符比较
	for i in range(prefix.length()):
		var text_char = text[offset + i]
		var prefix_char = prefix[i]
		if text_char != prefix_char:
			return false
	return true


const space_4 :String= "  "+"  "
	
