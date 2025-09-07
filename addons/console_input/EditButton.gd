extends Button


var http_request;

func _input(e):
#	if e is InputEventMouseButton and e.button_index==2:
#		# webhook to send CLEAR OUTPUT shc
#		var url = 'http://localhost:8080/DB.jsp?bat=D:/Code/FigureOut/chrome/extesions/AutoHotKey/gd_clear.ahk'
#		if not http_request:
#			http_request = HTTPRequest.new()
#			add_child(http_request)
#		http_request.request(url)
	pass
		
		

func _ready():
#	print('_ready::');
	mouse_filter = MOUSE_FILTER_STOP
	focus_mode = FOCUS_NONE


# 连接信号（可以在编辑器中连接，也可以在这里用代码连接）
func _enter_tree():
	pass
