@tool
extends Node3D
class_name AutoUpdate

#@export var test_health: int = 100
#@export var test_score: int = 0
@export var auto_update: bool = true

@export var eval_interval:float = 0

@export var check_shader_material: bool = false

@export var check_obj: Node = self : 
	set(v):
		check_obj = v
		exported_values.clear()

var eval_time = 0

var exported_values: Dictionary = {}

#func on_property_changed(prop_name: String, old_value, new_value):
	#print("Property '", prop_name, "' changed from ", old_value, " to ", new_value)

func on_property_update(key:String):
	print('on_property_update')
	pass


func is_export(usage):
	return (usage&PROPERTY_USAGE_EDITOR) and (usage&PROPERTY_USAGE_SCRIPT_VARIABLE )


func _process(delta: float):
	if Engine.is_editor_hint() and auto_update and get("visible") and eval_check(delta):
		eval_dump()
		
# Dump exported values
func eval_dump():
	var eval_obj := check_obj if check_obj!=null else self
	exported_values.clear()
	for prop in eval_obj.get_property_list():
		if not is_export (prop.usage ) :
			continue
		var key = prop.name
		var val = eval_obj.get(key);
		if val is ViewportTexture:
			continue
		if check_shader_material and val is ShaderMaterial:
			var shader_material:ShaderMaterial = val as ShaderMaterial
			var shader_uniforms = shader_material.shader.get_shader_uniform_list()
			for uniform_name in shader_uniforms:
				uniform_name = uniform_name.name
				#printt('uniform_name::', uniform_name);
				var parameter_value = shader_material.get_shader_parameter(uniform_name)
				if not parameter_value is ViewportTexture:
					exported_values[key+'_u_'+uniform_name] = parameter_value
					#printt("DUMP::  " + uniform_name + ": " + str(parameter_value))
		exported_values[key] = val
# Check exported values
func eval_check(delta: float):
	eval_time += delta
	if eval_time < eval_interval:
		return
	eval_time = 0
	var eval_obj := check_obj if check_obj!=null else self
	if not exported_values.size():
		eval_dump()
	var updated = 0;
	var props = eval_obj.get_property_list()
	#print('props_sz=', props.size())
	var key_changed = ""
	for prop in props:
		if not is_export(prop.usage) :
			continue
		#print(prop)
		var key = prop.name
		var now = eval_obj.get(key)
		if now is ViewportTexture:
			continue
		var prev = exported_values.get(key, null)
		if now != prev:
			updated = 1
			key_changed = key
			break
		if check_shader_material and now is ShaderMaterial:
			var shader_material:ShaderMaterial = now as ShaderMaterial
			var shader_uniforms = shader_material.shader.get_shader_uniform_list()
			for uniform_name in shader_uniforms:
				uniform_name = uniform_name.name
				now = shader_material.get_shader_parameter(uniform_name)
				if not now is ViewportTexture:
					prev = exported_values[key+'_u_'+uniform_name]
					#printt("CHECK::  " + uniform_name + ": " + str(now)+ " vs " + str(prev), prev==now)
					if now != prev:
						updated = 1
						key_changed = key
						break
			if updated:
				break
#			on_property_changed(key, prev, now)
	if updated:
		on_property_update(key_changed)
	return updated
