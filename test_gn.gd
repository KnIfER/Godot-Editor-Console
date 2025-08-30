extends Node3D


# Test Console::
# =gn("%test_gn")    ==>  Node3D
# =gn("%test_gn").process_mode    ===> default is zero
# gn("%test_gn").process_mode = 4  ==> the node is disabled !

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print("run")
	pass
