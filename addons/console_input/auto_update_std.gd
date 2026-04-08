@tool
extends Node


@export var listen_all_nodes:=true ## ignore targets and listen to all nodes
@export var skip_built_in_props: bool = false ## only listen to @export properties

@export var skip_invisible_node:=true ## only listen to visible nodes
@export var time_interval:float = 0 ## prevent calling too frequent

@export var add_target:Node=null: ## drag nodes here or click "assign". 
	set(v):
		if v:
			listen_all_nodes = false
			if(targets.find(add_target)<0):
				targets.push_back(v)

@export var targets:Array[Node]=[] ## nodes to listen

	
var lastUpdateTime:=0	
func is_wait_ready():
	var now = Time.get_unix_time_from_system()*1000
	if now-lastUpdateTime >= time_interval:
		lastUpdateTime = now
		return true
	return false
	
func is_node_valid(node, key):
	if node.has_method("on_property_update"):
		if !skip_invisible_node || node.get("visible"):
			if skip_built_in_props:
				var props = node.get_property_list()
				for prop in props:
					if prop.name==key :
						return AutoUpdate.is_export(prop.usage)
			else:
				return true
	return false


# func on_property_update(prop):
# 	printt("prop::", prop)

var _inspector
func property_update_handler(prop):
	# printt("prop::", prop)
	if time_interval==0 or is_wait_ready():
		if !skip_invisible_node || self.get("visible"):
			if listen_all_nodes:
				var node = _inspector.get_edited_object()
				if node!=self:
					if is_node_valid(node, prop):
						node.on_property_update(prop)
			else:
				for node in targets:
					if is_node_valid(node, prop):
						node.on_property_update(prop)

func _ready():
	if Engine.is_editor_hint():
#		var inspector = EditorInterface.get_inspector()
		var inspector = DDD.editor_interface.get_inspector()
		_inspector = inspector
		inspector.property_edited.connect(property_update_handler)


func _exit_tree() -> void:
	if _inspector:
		_inspector.property_edited.disconnect(property_update_handler)
	
