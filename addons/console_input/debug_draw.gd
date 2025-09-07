@tool
## @brief Single-file autoload for debug drawing and printing.
## Draw and print on screen from anywhere in a single line of code.
## Find it quickly by naming it "DDD".

# TODO Thread-safety
# TODO 2D functions

extends CanvasLayer


## @brief How many frames HUD text lines remain shown after being invoked.
const TEXT_LINGER_FRAMES = 5
## @brief How many frames lines remain shown after being drawn.
const LINES_LINGER_FRAMES = 1
## @brief Color of the text drawn as HUD
const TEXT_COLOR = Color.WHITE
## @brief Background color of the text drawn as HUD
const TEXT_BG_COLOR = Color(0.3, 0.3, 0.3, 0.8)
## @brief font size used for debug text
const TEXT_SIZE = 12

var tag0
var tag1
# 2D

var _canvas_item : CanvasItem = null
var _texts := {}
var _font : Font = null

# 3D

var _boxes := []
var _box_pool := []
var _box_mesh : Mesh = null
var _line_material_pool := []

var _lines := []
var _line_immediate_mesh : ImmediateMesh


func _ready():
	# Always process even if the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Draw 2D on top of every other CanvasLayer
	layer = 100
	_line_immediate_mesh = ImmediateMesh.new()
	var immediate_mesh_instance = MeshInstance3D.new()
	immediate_mesh_instance.material_override = _get_line_material()
	immediate_mesh_instance.mesh = _line_immediate_mesh
	add_child(immediate_mesh_instance)


## @brief Draws the unshaded outline of a 3D cube.
## @param position: world-space position of the center of the cube
## @param size: size of the cube in world units
## @param color
## @param linger_frames: optionally makes the box remain drawn for longer
func draw_cube(position: Vector3, size: float, color: Color = Color.WHITE, linger := 0):
	draw_box(position, Vector3(size, size, size), color, linger)


## @brief Draws the unshaded outline of a 3D box.
## @param position: world-space position of the center of the box
## @param size: size of the box in world units
## @param color
## @param linger_frames: optionally makes the box remain drawn for longer
func draw_box(position: Vector3, size: Vector3, color: Color = Color.WHITE, linger_frames = 0):
	var mi := _get_box()
	var mat := _get_line_material()
	mat.albedo_color = color
	mi.material_override = mat
	mi.position = position
	mi.scale = size
	_boxes.append({
		"node": mi,
		"frame": Engine.get_frames_drawn() + LINES_LINGER_FRAMES + linger_frames
	})


## @brief Draws the unshaded outline of a 3D transformed cube.
## @param trans: transform of the cube. The basis defines its size.
## @param color
func draw_transformed_cube(trans: Transform3D, color: Color = Color.WHITE):
	var mi := _get_box()
	var mat := _get_line_material()
	mat.albedo_color = color
	mi.material_override = mat
	mi.transform = Transform3D(trans.basis, trans.origin)
	_boxes.append({
		"node": mi,
		"frame": Engine.get_frames_drawn() + LINES_LINGER_FRAMES
	})


## @brief Draws the basis of the given transform using 3 lines
##        of color red for X, green for Y, and blue for Z.
## @param transform
## @param scale: extra scale applied on top of the transform
func draw_axes(transform: Transform3D, scale = 1.0):
	draw_ray_3d(transform.origin, transform.basis.x, scale, Color(1,0,0))
	draw_ray_3d(transform.origin, transform.basis.y, scale, Color(0,1,0))
	draw_ray_3d(transform.origin, transform.basis.z, scale, Color(0,0,1))


## @brief Draws the unshaded outline of a 3D box.
## @param aabb: world-space box to draw as an AABB
## @param color
## @param linger_frames: optionally makes the box remain drawn for longer
func draw_box_aabb(aabb: AABB, color = Color.WHITE, linger_frames = 0):
	var mi := _get_box()
	var mat := _get_line_material()
	mat.albedo_color = color
	mi.material_override = mat
	mi.position = aabb.position
	mi.scale = aabb.size
	_boxes.append({
		"node": mi,
		"frame": Engine.get_frames_drawn() + LINES_LINGER_FRAMES + linger_frames
	})


## @brief Draws an unshaded 3D line.
## @param a: begin position in world units
## @param b: end position in world units
## @param color
func draw_line_3d(a: Vector3, b: Vector3, color: Color):
	_lines.append([
		a, b, color,
		Engine.get_frames_drawn() + LINES_LINGER_FRAMES,
	])


## @brief Draws an unshaded 3D line defined as a ray.
## @param origin: begin position in world units
## @param direction
## @param length: length of the line in world units
## @param color
func draw_ray_3d(origin: Vector3, direction: Vector3, length: float, color : Color):
	draw_line_3d(origin, origin + direction * length, color)


## @brief Adds a text monitoring line to the HUD, from the provided value.
## It will be shown as such: - {key}: {text}
## Multiple calls with the same `key` will override previous text.
## @param key: identifier of the line
## @param text: text to show next to the key
func set_text(key: String, value=""):
	_texts[key] = {
		"text": value if typeof(value) == TYPE_STRING else str(value),
		"frame": Engine.get_frames_drawn() + TEXT_LINGER_FRAMES
	}


func _get_box() -> MeshInstance3D:
	var mi : MeshInstance3D
	if len(_box_pool) == 0:
		mi = MeshInstance3D.new()
		if _box_mesh == null:
			_box_mesh = _create_wirecube_mesh(Color.WHITE)
		mi.mesh = _box_mesh
		add_child(mi)
	else:
		mi = _box_pool[-1]
		_box_pool.pop_back()
	return mi


func _recycle_box(mi: MeshInstance3D):
	mi.hide()
	_box_pool.append(mi)


func _get_line_material() -> StandardMaterial3D:
	var mat : StandardMaterial3D
	if len(_line_material_pool) == 0:
		mat = StandardMaterial3D.new()
		mat.flags_unshaded = true
		mat.vertex_color_use_as_albedo = true
	else:
		mat = _line_material_pool[-1]
		_line_material_pool.pop_back()
	return mat


func _recycle_line_material(mat: StandardMaterial3D):
	_line_material_pool.append(mat)


func _process(delta: float):
	_process_boxes()
	_process_lines()
	_process_canvas()


func _process_3d_boxes_delayed_free(items: Array):
	var i := 0
	while i < len(items):
		var d = items[i]
		if d.frame <= Engine.get_frames_drawn():
			_recycle_line_material(d.node.material_override)
			d.node.queue_free()
			items[i] = items[len(items) - 1]
			items.pop_back()
		else:
			i += 1


func _process_boxes():
	_process_3d_boxes_delayed_free(_boxes)

	# Progressively delete boxes in pool
	if len(_box_pool) > 0:
		var last = _box_pool[-1]
		_box_pool.pop_back()
		last.queue_free()


func _process_lines():
	var im := _line_immediate_mesh
	im.clear_surfaces()

	if len(_lines) == 0:
		return

	im.surface_begin(Mesh.PRIMITIVE_LINES)
	
	for line in _lines:
		var p1 : Vector3 = line[0]
		var p2 : Vector3 = line[1]
		var color : Color = line[2]
		
		im.surface_set_color(color)
		im.surface_add_vertex(p1)
		im.surface_add_vertex(p2)
	
	im.surface_end()
	
	# Delayed removal
	var i := 0
	while i < len(_lines):
		var item = _lines[i]
		var frame = item[3]
		if frame <= Engine.get_frames_drawn():
			_lines[i] = _lines[len(_lines) - 1]
			_lines.pop_back()
		else:
			i += 1


func _process_canvas():
	# Remove text lines after some time
	for key in _texts.keys():
		var t = _texts[key]
		if t.frame <= Engine.get_frames_drawn():
			_texts.erase(key)

	# Update canvas
	if _canvas_item == null:
		_canvas_item = Node2D.new()
		_canvas_item.position = Vector2(8, 8)
		_canvas_item.draw.connect(_on_CanvasItem_draw)
		add_child(_canvas_item)
	_canvas_item.queue_redraw()


func _on_CanvasItem_draw():
	var ci := _canvas_item
	
	var font : Font = SystemFont.new()


	var ascent := Vector2(0, font.get_ascent())
	var pos := Vector2()
	var xpad := 2
	var ypad := 1
	var font_offset := ascent + Vector2(xpad, ypad)
	var line_height := font.get_height() + 2 * ypad

	for key in _texts.keys():
		var t = _texts[key]
		var text := str(key, ": ", t.text)
		var ss := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, TEXT_SIZE)
		ci.draw_rect(Rect2(pos, Vector2(ss.x + xpad * 2, line_height)), TEXT_BG_COLOR)
		ci.draw_string(font, pos + font_offset, text, HORIZONTAL_ALIGNMENT_LEFT, -1, TEXT_SIZE,
			TEXT_COLOR)
		pos.y += line_height


static func _create_wirecube_mesh(color := Color.WHITE) -> ArrayMesh:
	var n = -0.5
	var p = 0.5
	var positions := PackedVector3Array([
		Vector3(n, n, n),
		Vector3(p, n, n),
		Vector3(p, n, p),
		Vector3(n, n, p),
		Vector3(n, p, n),
		Vector3(p, p, n),
		Vector3(p, p, p),
		Vector3(n, p, p)
	])
	var colors := PackedColorArray([
		color, color, color, color,
		color, color, color, color,
	])
	var indices := PackedInt32Array([
		0, 1,
		1, 2,
		2, 3,
		3, 0,

		4, 5,
		5, 6,
		6, 7,
		7, 4,

		0, 4,
		1, 5,
		2, 6,
		3, 7
	])
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = positions
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	return mesh



func get_root():
	return get_node("/root")
	
func print_nodes(node: Node = null, indent: int = 0):
	if node==null and indent==0:
		node = get_root()
	var spaces = ""
	for i in range(indent):
		spaces += "=="
	if spaces:
		spaces += ">"
	print(spaces + node.get_class() + ": " + node.name)
	
	for child in node.get_children():
		print_nodes(child, indent + 1)

static func _get_scene(n):
	var ret = null
	if n.get_child_count()>0:
		for cn in n.get_children():
			if cn is Node3D:
				ret = cn
				break
			else :
				ret = _get_scene(cn)
				if ret:
					break
	return ret

var scene
var scene_absolute
func set_scene(s, ab = false):
	scene = s
	scene_absolute = ab
func get_scene():
	if scene and is_instance_valid(scene):
		return scene
	scene = _get_scene(get_node("/root"))
	scene_absolute = false
	return scene

func gn(e:String,n:Node=null):
	if n==null:
		n = get_root()
	return FU.gn(e, n);	
	
func gc(e:String,n:Node=null):
	if n==null:
		n = get_root()
	return FU.gc(e, n);	

var arrow_body:StandardMaterial3D=null
var arrow_head :StandardMaterial3D=null

func ensure_arrow_materials():
	if not arrow_body:
		arrow_body = StandardMaterial3D.new()
		arrow_head = StandardMaterial3D.new()
		arrow_body.albedo_color = Color.BLUE
		arrow_body.metallic = 0.2
		arrow_body.roughness = 0.8
		arrow_head.albedo_color = Color.RED
	
	
func arrow_body_color(c, arrow=0):
	if arrow:
		var material = StandardMaterial3D.new()
		material.albedo_color = c
		material.metallic = 0.2
		material.roughness = 0.8
		gn("body", arrow).material = material
	else:
		ensure_arrow_materials()
		arrow_body.albedo_color = c
	
func arrow_head_color(c, arrow=0):
	if arrow:
		var material = StandardMaterial3D.new()
		material.albedo_color = c
		gn("head", arrow).material = material
	else:
		ensure_arrow_materials()
		arrow_head.albedo_color = c
	
func vvv(pos, direction=0, scale=1):
	ensure_arrow_materials()
	var body = CSGCylinder3D.new()
	body.radius = 0.05
	body.height = 1.0
	body.position = Vector3(0, 0.5, 0)  # 将头部放置在主体的一端
	# head
	var head = CSGCylinder3D.new()
	head.height = 0.3
	head.radius = 0.1
	head.cone = true
	head.position = Vector3(0, 0.65+0.5, 0)  # 将头部放置在主体的一端
	var arrow = Node3D.new()
	arrow.add_child(body)
	arrow.add_child(head)
	
	arrow.scale = Vector3(scale,scale,scale)
	
	var arrowP = Node3D.new()
	arrowP.add_child(arrow)
	get_scene().add_child(arrowP)
	
	if scene_absolute:
		arrowP.global_position = pos
	else:
		arrowP.position = pos
	
	
	head.owner = get_tree().edited_scene_root
	body.owner = get_tree().edited_scene_root
	arrow.owner = get_tree().edited_scene_root
	arrowP.owner = get_tree().edited_scene_root
	
	if direction and direction != Vector3.ZERO:
		var from: Vector3 = Vector3(0, 1, 0) 
		arrowP.global_transform.basis = Basis(FU.from_to_rotation(from, direction))
	body.name = "arrow_body";
	head.name = "arrow_head";
	body.material = arrow_body
	head.material = arrow_head
	return arrowP
