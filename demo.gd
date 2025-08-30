#@tool
extends Node3D


# project settings -> autoreload tab -> add name=DDD, path=res://addons/console_input/debug_draw.gd

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	DDD.set_text("hell0"+str(delta))
	pass
