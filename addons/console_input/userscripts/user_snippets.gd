## warning :: Don't modify this file, create your_snippets.gd instead!


func math(a,b):
	return a+b

## methods in this file (xx_snippets.gd) will be extracted to tools menu (if the name starts with __ (double underscore)
##  make sure it has 2 args : editor, plugin

# func __print_hello(editor:EditorInterface, plugin:EditorPlugin):
# 	printt(editor, plugin)
	

## simplest demo : 
# func __test_math(editor, plugin):
# 	printt("1+1=", math(1,1))



## string restults will be evaluated
# func __test_eval_scroll(editor, plugin):
# 	return """#var inspector = EditorInterface.get_inspector() # requires godot 4.3
# var inspector = _et_.get_inspector() # _et_ is eidtor interface
# var bar  = inspector.get_v_scroll_bar()
# inspector.scroll_vertical  = bar.max_value"""

## note the script is re-instantiated on each run due to hot-reload issues
##   so variable are  not stored at all !
# var cc:=0 # won't work
# func __test_add(editor, plugin, data):
# 	cc+=1
# 	printt("cc=", cc)

# using data for this script
func __test_user_script(editor, plugin, data):
	var cc=FU.get_or_add(data, 'cc', 0) # FU.get_or_add for compatibiliy
	cc+=1
	printt("cc=", cc)
	data["cc"] = cc
	
func __shallow_duplicate(editor, plugin, data):
	return """FU.shallow_duplicate(sn())"""
