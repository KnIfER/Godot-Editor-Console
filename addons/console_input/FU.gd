
#extends Node
class_name FU

static func debug():
	return Engine.is_editor_hint()
	
static func add_child(obj, ch):
	obj.add_child(ch)
	if Engine.is_editor_hint():
		ch.owner = obj.get_tree().edited_scene_root
	
static func add_sibling(obj, ch):
	obj.add_sibling(ch)
	if Engine.is_editor_hint():
		ch.owner = obj.get_tree().edited_scene_root
	
static func remove_childs(obj):
	for node in obj.get_children():
		node.queue_free()
	
static func now()->int:
	return int(Time.get_unix_time_from_system()*1000)
	
static func get_system_time_msecs():
	return int(Time.get_unix_time_from_system()*1000)

static func build_rotation_from_axes(right: Vector3, up: Vector3) -> Vector3:
	# Normalize the input vectors
	var x_axis = right.normalized()
	var y_axis = up.normalized()
	# Calculate the forward vector and ensure orthogonality
	var z_axis = x_axis.cross(y_axis).normalized()
	y_axis = z_axis.cross(x_axis).normalized()
	# Create a basis and convert to quaternion for stability
	var basis = Basis(x_axis, y_axis, z_axis)
	var quat = Quaternion(basis)
	# Convert quaternion to Euler angles
	var rot = quat.get_euler()
	
	#var min_angle_rad = atan2(2.5,352);
	##printt('min_angle_rad::', min_angle_rad, min_angle_rad/PI*180);
	#rot.x = round(rot.x / min_angle_rad) * min_angle_rad
	#rot.y = round(rot.y / min_angle_rad) * min_angle_rad
	#rot.z = round(rot.z / min_angle_rad) * min_angle_rad
	return rot

	
	
static func point_up_toward(obj:Node3D, fa:Vector3):
	fa = fa.normalized()
	var vx = -fa.z
	var vz = fa.x
	var vy = 0

	var dot_vu = vx * fa.x + vy * fa.y + vz * fa.z
	vx -= dot_vu * fa.x
	vy -= dot_vu * fa.y
	vz -= dot_vu * fa.z

	var right = -Vector3(vx,vy,vz)

	var rotation = build_rotation_from_axes(right, fa)
	obj.rotation = rotation


static func point_up_toward1(obj: Node3D, up_direction: Vector3):
	# 确保上方向向量归一化
	var fa = up_direction.normalized()
	
	# 计算右方向向量（与上方向垂直）
	var temp = Vector3(0, 1, 0)
	if fa.is_equal_approx(temp) or fa.is_equal_approx(-temp):
		# 特殊情况：当上方向接近Y轴时使用X轴作为参考
		temp = Vector3(1, 0, 0)
	
	var right = fa.cross(temp).normalized()
	# 确保右方向与上方向严格垂直
	right = right - right.project(fa)
	right = right.normalized()
	
	# 获取旋转欧拉角并应用
	var rotation = build_rotation_from_axes(right, fa)
	obj.rotation = rotation

static func hhmm():
	var now = Time.get_datetime_string_from_system()
	var time_parts = now.split("T")[1].split(":")
	var hour = time_parts[0]
	var minute = time_parts[1]
	var time_str = "%s:%s" % [hour, minute]
	return time_str

static func _gn(e, n):
	var ret = null
	if n.get_child_count()>0:
		for cn in n.get_children():
			if cn.name.find(e)>=0:
				ret = cn
				break
			else :
				ret = _gn(e, cn)
				if ret:
					break
	return ret

static func gn(e:String,n:Node=null):
	if n==null:
		return null
	if n.name.find(e)>=0:
		return n
	return _gn(e, n);

static func _gc(e, n):
	var ret = null
	if n.get_child_count()>0:
		for cn in n.get_children():
			# printt("get_basename::", cn.get_class().get_basename())
			if cn.get_class().get_basename()==e:
				ret = cn
				break
			else :
				ret = _gc(e, cn)
				if ret:
					break
	return ret

static func gc(e:String,n:Node=null):
	if n==null:
		return null
	if n.get_class().get_basename()==e:
		return n
	return _gc(e, n);	


static func read_all(filePath):
	var file = FileAccess.open(filePath, FileAccess.READ)
	var content = file.get_as_text()
	return content

static func vvv(x,y,z):
	return Vector3(x,y,z)

static func from_to_rotation(source: Vector3, target: Vector3):
	var source_norm = source.normalized()
	var target_norm = target.normalized()
	var dot = source_norm.dot(target_norm)
	if dot > 0.999999: # 如果向量方向相同，返回单位四元数（无旋转）
		return Quaternion()
	if dot < -0.999999: # 如果向量方向相反，计算垂直向量作为旋转轴
		var axis = Vector3(1, 0, 0).cross(source_norm)
		if axis.length_squared() < 0.000001:
			axis = Vector3(0, 1, 0).cross(source_norm)
		axis = axis.normalized()
		return Quaternion(axis, PI)
	var axis = source_norm.cross(target_norm).normalized()
	var angle = acos(dot)
	return Quaternion(axis, angle)


static func getTmpText():
	return DisplayServer.clipboard_get()
	
static func setTmpText(str):
	DisplayServer.clipboard_set(str(str))


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


static func ensure_size(output_array, size) :
	if(output_array.size()<=size):
		output_array.append(Vector4.ZERO)

static func setVec4i(output_array, cc, r,g,b,a):
	if(output_array.size()<=cc*4):
		output_array.append(0)
		output_array.append(0)
		output_array.append(0)
		output_array.append(0)
	output_array.set(cc*4, r)
	output_array.set(cc*4 + 1, g)
	output_array.set(cc*4 + 2, b)
	output_array.set(cc*4 + 3, a)


static func load_external_tex(path):
	# if exists(path):
	var tex_file = FileAccess.open(path, FileAccess.READ)
	if not tex_file:
		push_error("无法打开文件: ", path)
		return null
	var bytes = tex_file.get_buffer(tex_file.get_length())
	tex_file.close()  # 可以提前关闭文件，因为已经获取了所有数据
	var img = Image.new()
	# 在 Godot 4 中，load_png_from_buffer 改为返回 Error 枚举
	var error = img.load_png_from_buffer(bytes)
	if error != OK:
		push_error("PNG 加载失败: ", error)
		return null
	var imgtex := ImageTexture.create_from_image(img)
	return imgtex
	# return null

static func load_tex(path):
	if exists(path):
		return load(path)
	return null
	
static func cloneMaterial(src)->Material:
	var ret :=			ShaderMaterial.new()
	ret.shader = src.shader
	for param in src.shader.get_shader_uniform_list():
		var v = src.get_shader_parameter(param.name)
		if v is Array:
			v = v.duplicate()
		ret.set_shader_parameter(param.name, v)
	return ret

static func repeatString(s: String, count: int) -> String:
	var res = ""
	for i in range(count):
		res += s
	return res

static func has_property(n,key) :
	var props = n.get_property_list()
	for prop in props:
		if prop.name==key :
			return true
	return false


static func enhance(ctrl,en=true) :
	ctrl.modulate = Color.YELLOW if en else Color.WHITE
	
	
static func log(parent, indent: int = 0):
	for child in parent.get_children():
		# if child is Control:
		var text = ""
		if FU.has_property(child, "text"):
			text = "  "+child.text
		print(FU.repeatString(" ", 4*indent) + child.get_class().get_basename()+"/"+child.name+text)
		FU.log(child, indent + 1)
	
#static func get_class_chain(node: Node) -> Array:
	#var chain = []
	#var current = node
	#while current:
		#chain.append(current.get_class())
		#current = current.get_parent() if current.get_parent() else null
	#return chain
	
static func nosuffix(filename: String) -> String:
	var last_dot = filename.rfind(".")
	if last_dot > 0:
		return filename.substr(0, last_dot)
	return filename
	
# static func class_for_name(cn: String):
# 	if ClassDB.class_exists(cn):
# 		return ClassDB.instantiate(cn)
# 	return null

static func get_or_add(dict: Dictionary, key, default_value):
	if not dict.has(key):
		dict[key] = default_value
	return dict[key]

static func shallow_clone_node(source: Node) -> Node:
	var clone = source.duplicate()
	remove_childs(clone)
	return clone

static func shallow_duplicate(node: Node3D) -> Node3D:
	var clone = shallow_clone_node(node)
	if node.get_parent():
		add_sibling(node, clone)
	clone.name = node.name + "_Clone"
	return clone

static func toggle_visible(nodes):
	var vis = !nodes[0].get("visible")
	for n in nodes:
		n.set("visible", vis)

static func run(code):
	return DDD.plugin.run_code(code)
