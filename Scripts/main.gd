extends Control

# Drag and Drop variables
var dragged_item = null
var grid_size = 32
var items_in_grid = []

# Called when the scene is ready
func _ready():
	pass

# Handles dragging from the top bar
func _on_item_dragged(item):
	dragged_item = item

# Handles dropping onto the grid
func _on_grid_drop(position):
	if dragged_item:
		var grid_position = position / grid_size
		grid_position.x = int(grid_position.x)
		grid_position.y = int(grid_position.y)

		var new_item = dragged_item.instance()
		new_item.position = grid_position * grid_size
		add_child(new_item)
		items_in_grid.append(new_item)

		dragged_item = null

# Called when the user presses play
func _on_play_button_pressed():
	for item in items_in_grid:
		if item.name == "Ball":
			item.set_physics_process(true)

func _on_stop_button_pressed():
	for item in items_in_grid:
		if item.name == "Ball":
			item.set_physics_process(false)
			item.position = item.position.snap(Vector2(grid_size, grid_size))

func _on_menu_button_pressed():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	SceneTree.quit
