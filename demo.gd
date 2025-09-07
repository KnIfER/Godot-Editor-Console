#@tool
extends Node3D





# project settings -> autoreload tab -> add name=DDD, path=res://addons/console_input/debug_draw.gd

# Called when the node enters the scene tree for the first time.
func _ready():
	DDD.vvv(Vector3(0, 0, 0), Vector3(0, 1, 0), 1)
	DDD.vvv(FU.vvv(0, 0, 0), FU.vvv(1, 0, 0), 2)
	
	var arrow = DDD.vvv(FU.vvv(0, 0, 0), FU.vvv(0, 0, 1), 2)
	DDD.arrow_head_color(Color(0,1,1), arrow)
