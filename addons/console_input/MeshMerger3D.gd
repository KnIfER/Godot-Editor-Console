@tool
class_name MeshMerger3D
extends MeshInstance3D

var result_mesh:ArrayMesh
var result_mesh_material:Material

@export var collision_parent: Node

@export var btn_merge_meshes: bool: 
	set(value): merge_meshes(value)
	get: return btn_merge_meshes

@export var btn_clean_meshes: bool:
	set(value): clean_meshes(value)
	get: return btn_clean_meshes

@export var delete_child_meshes_on_play: bool:
	set(value):
		set_delete_child_meshes_on_play(value)
	get: return delete_child_meshes_on_play

func merge_meshes(_value):
	# if !Engine.is_editor_hint():
	# 	return

	if result_mesh:
		result_mesh.clear_surfaces()
	
	if collision_parent:
		clean_collisions()

	var st := SurfaceTool.new()

	printt("get_children::", get_children())
	for node in get_children():
		printt("append_from::", node)
		if node is MeshInstance3D:
			st.append_from(node.mesh, 0, node.transform)
			grab_material(node)
			generate_collisions(node)

	result_mesh = st.commit()
	printt("result_mesh::111", result_mesh)
	
	self.mesh = result_mesh
	self.material_override = result_mesh_material
	return result_mesh

func clean_meshes(_value):
	if !Engine.is_editor_hint():
		return

	mesh = ArrayMesh.new()
	clean_collisions()

func grab_material(node):
	if node.get_active_material(0):
		result_mesh_material = node.get_active_material(0)
	elif node.mesh.surface_get_material(0):
		result_mesh_material = node.mesh.get_active_material(0)

func generate_collisions(node):
	if !collision_parent:
		return
	for child in node.get_children():
		if child is StaticBody3D and child.get_child_count() > 0:
			for grandchild in child.get_children():
				if grandchild is CollisionShape3D:
					var new_col := CollisionShape3D.new()
					new_col.global_transform = child.global_transform
					collision_parent.add_child(new_col)
					new_col.shape = grandchild.shape
					new_col.set_owner(get_tree().get_edited_scene_root())

func clean_collisions():
	if !collision_parent:
		return
	if collision_parent.get_child_count() > 0:
		for child in collision_parent.get_children():
			child.queue_free()

func set_delete_child_meshes_on_play(value):
	delete_child_meshes_on_play = value

func _ready():
	if delete_child_meshes_on_play:
		for node in get_children():
			if node is MeshInstance3D:
				node.queue_free()
