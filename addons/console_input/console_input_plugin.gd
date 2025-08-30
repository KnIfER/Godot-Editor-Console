@tool
extends EditorPlugin

var console_scene: PackedScene
var console_instance: Control

func _enter_tree() :
	console_scene = preload("res://addons/console_input/console_input.tscn")
	console_instance = console_scene.instantiate()
	
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, console_instance)

	print('console_instance::', console_instance.get_script().get_path())
	console_instance.get_script().reload()
	
	var input:ConsoleUI = console_instance
	input.set_plugin_reference(self)
#	input.plugin = self
	
#	print("Console Input plugin enabled")

func _exit_tree() :
	remove_control_from_bottom_panel(console_instance)
	console_instance.queue_free()
	
	print("Console Input plugin disabled")
