
extends Node
class_name GU



static func convert_rgb8_to_r8(rgb_image: Image) -> Image:
	var width = rgb_image.get_width()
	var height = rgb_image.get_height()
	var r8_image = Image.new()
	r8_image.create(width, height, false, Image.FORMAT_R8)
	r8_image.copy_from(rgb_image)
	
	r8_image.convert(Image.FORMAT_R8)
	## 遍历每个像素，提取红色通道值
	#for y in range(height):
		#for x in range(width):
			## 获取RGB颜色值
			#var color = rgb_image.get_pixel(x, y)
			## 仅保留红色通道值，写入到R8图像
			#r8_image.set_pixel(x, y, Color(color.r, 0, 0))
	printt('r8_image::', r8_image, rgb_image.get_format() );
	return r8_image

static func blur_image(image: Image, radius: int) -> Image:
	if radius < 1:
		return image.duplicate()
	if not image:
		return null
	var w = image.get_width()
	var h = image.get_height()
	var temp = image.duplicate()
	var result = image.duplicate()
	var kernel_size = radius * 2 + 1
	var kernel = PackedFloat32Array()
	for i in range(kernel_size):
		var dx = i - radius
		kernel.append(exp(-dx * dx / (2.0 * radius * radius)))
	var sum = 0.0
	for v in kernel:
		sum += v
	for i in range(kernel_size):
		kernel[i] /= sum
	for y in range(h):
		for x in range(w):
			var color = Color(0, 0, 0)
			for k in range(kernel_size):
				var nx = x + k - radius
				nx = clamp(nx, 0, w - 1)
				var c = temp.get_pixel(nx, y)
				color += c * kernel[k]
			result.set_pixel(x, y, color)
	temp = result.duplicate()
	for y in range(h):
		for x in range(w):
			var color = Color(0, 0, 0)
			for k in range(kernel_size):
				var ny = y + k - radius
				ny = clamp(ny, 0, h - 1)
				var c = temp.get_pixel(x, ny)
				color += c * kernel[k]
			result.set_pixel(x, y, color)
	return result
