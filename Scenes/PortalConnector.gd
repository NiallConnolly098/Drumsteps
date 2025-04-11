extends Node2D

class_name PortalConnector

var portals = []

func _ready():
	# Make sure we draw above other objects
	z_index = 10

func _process(_delta):
	queue_redraw()  # Continuously redraw lines

func _draw():
	for i in range(0, portals.size(), 2):
		if i+1 < portals.size():
			var portal1 = portals[i]
			var portal2 = portals[i+1]
			if is_instance_valid(portal1) and is_instance_valid(portal2):
				var pos1 = portal1.position + Vector2(0, 64)
				var pos2 = portal2.position + Vector2(0, 64)
				# Draw faint dotted line between portals
				draw_dashed_line(
					pos1,
					pos2,
					Color(27, 137, 227, 0.7),  # Very faint white
					2.0,  # Width
					5.0,  # Dash length
					5.0   # Gap length
					)
