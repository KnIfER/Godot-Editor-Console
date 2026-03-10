class_name TU


#const pixel_bytes := 4

class MapData:
	var texture :Texture2D
	var image :Image
	var image_data :PackedByteArray
	var width: int
	var height: int
	var pixel_bytes: int
	
	func _init(heightmap_texture :Texture2D):
		self.texture = heightmap_texture
		self.image = heightmap_texture.get_image()
		self.image_data = self.image.get_data()
		self.width = heightmap_texture.get_width()
		self.height = heightmap_texture.get_height()
		self.pixel_bytes = 4
		
static func get_pixel_value(map: MapData, x: int, y: int) -> float:
	var index: int = (x + y * map.width) * map.pixel_bytes
	return float(map.image_data[index]) / 255.0


static func bilinear_sample(map: MapData, u: float, v: float) -> float:
	var width: int = map.width
	var height: int = map.height
	# 计算精确的浮点坐标
	var exact_x: float = u * width
	var exact_y: float = v * height
	# 获取四个相邻像素的整数坐标
	var x0: int = clamp(int(exact_x), 0, width - 1)
	var y0: int = clamp(int(exact_y), 0, height - 1)
	var x1: int = clamp(x0 + 1, 0, width - 1)
	var y1: int = clamp(y0 + 1, 0, height - 1)
	# 计算插值权重
	var tx: float = exact_x - x0
	var ty: float = exact_y - y0
	# 获取四个角点的值
	var value00: float = get_pixel_value(map, x0, y0)
	var value01: float = get_pixel_value(map, x0, y1)
	var value10: float = get_pixel_value(map, x1, y0)
	var value11: float = get_pixel_value(map, x1, y1)
	# 双线性插值计算
	var top_interp: float = lerp(value00, value10, tx)
	var bottom_interp: float = lerp(value01, value11, tx)
	return lerp(top_interp, bottom_interp, ty)
