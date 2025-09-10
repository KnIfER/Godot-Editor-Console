@tool
extends AutoUpdate

@export var eval := false:
	set(v):
		#printt('eval::', check_obj_path, find_obj());
		DDD.auto_running = true
		find_obj()._ready()
		DDD.auto_running = false
		eval_dump()
		
@export var hotkey_on_visible := false
	
#@export var check := false:
#	set(v):
#		if eval_check(999):
#			eval_dump()
			

func on_property_update(key:String):
	printt('on_property_update::', key);
	find_obj()._ready()


func _process(delta: float) -> void:
	#printt('_process::', wparam);
	if Input.is_action_just_pressed("auto_run"):
		DDD.set_text("auto_run\nauto_run\nauto_run\n")
		DDD.auto_running = true
		find_obj()._ready()
		DDD.auto_running = false
		return
	super._process(delta)

func _ready() -> void:
	if Engine.is_editor_hint():
		var has_key = InputMap.has_action("auto_run")
		if not has_key:
			InputMap.erase_action("auto_run")
			InputMap.add_action("auto_run")
			var event := InputEventKey.new()
			event.keycode = KEY_R
			event.command_or_control_autoremap = true
			event.shift_pressed = true
			event.ctrl_pressed = true
			InputMap.action_add_event("auto_run", event)
