extends StaticBody2D

var global_node = null

func _ready():
	print("SimulationStep ready!")
	if global_node:
		print("Global node found: ", global_node)
	else:
		print("Global node not found!")
