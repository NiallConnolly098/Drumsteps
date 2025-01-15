extends Control

var grid_size = 64  # Size of each grid cell

func _ready():
	# Trigger the draw function
	pass

func _draw():
	var size = get_rect().size

	# Draw vertical grid lines
	for x in range(0, int(size.x), grid_size):
		draw_line(Vector2(x, 0), Vector2(x, size.y), Color(0.8, 0.8, 0.8), 1)

	# Draw horizontal grid lines
	for y in range(0, int(size.y), grid_size):
		draw_line(Vector2(0, y), Vector2(size.x, y), Color(0.8, 0.8, 0.8), 1)
