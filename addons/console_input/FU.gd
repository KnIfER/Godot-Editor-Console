
extends Node
class_name FU


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
	DisplayServer.clipboard_set(str)


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
