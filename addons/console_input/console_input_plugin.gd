@tool
extends EditorPlugin

const PREFIX: StringName = &"plugin/console_input/"

## Editor setting for the shortcut
const RUN_TEXT: StringName = PREFIX + &"run_text"
var run_text_shc: Shortcut


var console_scene: PackedScene
var console_instance: ConsoleUI

func _enter_tree() :
	add_autoload_singleton("DDD", "res://addons/console_input/debug_draw.tscn")
	add_autoload_singleton("FPS", "res://addons/console_input/debug_menu.tscn")


	console_scene = preload("res://addons/console_input/console_input.tscn")
	console_instance = console_scene.instantiate()
	
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, console_instance)


	init_shortcuts()
	
	var input:ConsoleUI = console_instance
	input.set_plugin_reference(self)
#	input.plugin = self
	
#	print("Console Input plugin enabled")

	# not work
#	var file_system: EditorFileSystem = get_editor_interface().get_resource_filesystem()
#	file_system.filesystem_changed.connect(schedule_update)

	get_editor_settings().settings_changed.connect(sync_settings)


## Schedules an update on the next frame
func schedule_update():
#	get_script().reload()
	console_instance.get_script().reload()
	set_process(true)
	printt('reload...');
	
func _process(delta: float) -> void:
	set_process(false)

func _exit_tree() :
	remove_control_from_bottom_panel(console_instance)
	console_instance.queue_free()
	
	print("Console Input plugin disabled")

func _shortcut_input(event: InputEvent) -> void:
	if (!event.is_pressed() || event.is_echo()):
		return
	if (run_text_shc.matches_event(event)):
		get_viewport().set_input_as_handled()
		console_instance.run_clipboard()


func get_editor_settings() -> EditorSettings:
	return get_editor_interface().get_editor_settings()
	
func init_shortcuts():
	var editor_settings: EditorSettings = get_editor_settings()
	if (!editor_settings.has_setting(RUN_TEXT)):
		var shortcut: Shortcut = Shortcut.new()
		var event: InputEventKey = InputEventKey.new()
		event.device = -1
		#event.command_or_control_autoremap = true
		event.keycode = KEY_F12
		shortcut.events = [ event ]
		editor_settings.set_setting(RUN_TEXT, shortcut)
	run_text_shc = editor_settings.get_setting(RUN_TEXT)
	
func get_shortcut(property: StringName) -> Shortcut:
	return get_editor_settings().get_setting(property)
	
var suppress_settings_sync

func sync_settings():
	if (suppress_settings_sync):
		return
	var changed_settings: PackedStringArray = get_editor_settings().get_changed_settings()
	for tmp in changed_settings:
		var setting: =tmp as String
		if (setting == RUN_TEXT):
			run_text_shc = get_shortcut(RUN_TEXT)
