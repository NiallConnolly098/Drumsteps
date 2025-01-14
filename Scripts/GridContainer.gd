extends GridContainer

var cell_size: Vector2

func _ready():
	# Assume all cells are the same size, get size from the first child
	if get_child_count() > 0:
		cell_size = get_child(0).rect_size

func drop_item(item):
	# Calculate which cell the item is dropped on
	var grid_position = get_global_mouse_position() - global_position
	var cell_x = int(grid_position.x / cell_size.x)
	var cell_y = int(grid_position.y / cell_size.y)
	
	# Ensure the drop is within bounds
	if cell_x < 0 or cell_x >= columns or cell_y < 0 or cell_y >= (get_child_count() / columns):
		return
	
	# Snap the item to the center of the target cell
	var target_position = Vector2(cell_x * cell_size.x, cell_y * cell_size.y) + global_position
	item.position = target_position
	print("Item dropped at cell:", cell_x, cell_y)
