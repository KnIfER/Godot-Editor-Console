class_name ui_util_smippets

func __scroll_scenetree_up_down(editor, plugin):
	plugin.keepMenuOpen = 1
	return """
var scene = FU.gc("SceneTreeDock", _et_.get_base_control())
var n = FU.gc("Tree", scene)
var scroll=n.get_scroll()
if scroll.y==0:
	n.scroll_to_item(n.get_root().get_children()[-1])
else:
	n.scroll_to_item(n.get_root())
"""


func __scroll_inspector_up_down(editor, plugin):
	plugin.keepMenuOpen = 1
	return """
var inspector = _et_.get_inspector()
var bar  = inspector.get_v_scroll_bar()
inspector.scroll_vertical  = 0 if inspector.scroll_vertical>=bar.max_value-inspector.size.y else bar.max_value
"""

func __toggle_disable_selected_nodes(editor, plugin):
	return """kn()"""

var move_dlg:Panel

func __batch_move_selected_nodes(editor:EditorInterface, plugin):
	var nodes = editor.get_selection().get_selected_nodes()
	if move_dlg:
		move_dlg.queue_free()
	var panel := Panel.new()
	panel.custom_minimum_size = Vector2(320, 160)
	panel.position = (editor.get_viewport().get_visible_rect().size - panel.custom_minimum_size) / 2

	# 标题
	var label_title = Label.new()
	label_title.text = "title"
	label_title.position = Vector2(10, 10)
	label_title.add_theme_font_size_override("font_size", 18)
	panel.add_child(label_title)

	# 内容
	var label_msg = Label.new()
	label_msg.text = "message"
	label_msg.position = Vector2(10, 40)
	panel.add_child(label_msg)

	# 关闭按钮
	var btn = Button.new()
	btn.text = "确定"
	btn.position = Vector2(320 - 100 - 10, 160 - 40)
	btn.size = Vector2(100, 30)
	panel.add_child(btn)
	
	btn.pressed.connect(func():
		panel.queue_free()
	)

	
	move_dlg = panel
#	panel.show()
	editor.get_base_control().add_child(panel)
	
	
