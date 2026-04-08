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



func __batch_move_selected_nodes(editor:EditorInterface, plugin, data):
	var lastMoveDelta=FU.get_or_add(data, 'moved', Vector3.ZERO)
	
	var nodes = editor.get_selection().get_selected_nodes()
		
	var panel_bg := Panel.new()
	panel_bg.custom_minimum_size = editor.get_viewport().get_visible_rect().size
	panel_bg.modulate = Color(1, 1, 1, 0)  # alpha = 0
	
	var panel := Panel.new()
	panel.custom_minimum_size = Vector2(380, 160)
	panel.position = (editor.get_viewport().get_visible_rect().size - panel.custom_minimum_size) / 2
	
	panel_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	panel_bg.gui_input.connect(func(event):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				panel_bg.queue_free()
				panel.queue_free()
		)
		
	# 创建输入控件
	var grid := GridContainer.new()
	grid.columns = 6
	panel.add_child(grid)
	var spins = []
	var make_col = func (n):
		var label = Label.new()
		label.text = n+" ："
		grid.add_child(label)
		var spin = SpinBox.new()
		spin.min_value = -99999
		spin.max_value = 99999
		spin.step = 0.1
		spin.value = lastMoveDelta[spins.size()]
		grid.add_child(spin)
		spins.push_back(spin)
	
	for n in ['X', 'Y', 'Z']:
		make_col.call(n)

	var btn = Button.new()
	btn.text = "Move Selected"
	btn.position = Vector2(320 - 200 - 10, 160 - 40)
	btn.size = Vector2(250, 30)
	panel.add_child(btn)
	
	btn.pressed.connect(func():
		panel.queue_free()
		panel_bg.queue_free()
		lastMoveDelta = Vector3(spins[0].value, spins[1].value, spins[2].value)
		for node in nodes:
			if node is Node3D:
				node.position += lastMoveDelta
	)
	
	editor.get_base_control().add_child(panel_bg)
	editor.get_base_control().add_child(panel)
	
	
