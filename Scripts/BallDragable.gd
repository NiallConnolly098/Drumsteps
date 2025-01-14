extends TextureRect

var is_dragging = false
var drag_start_position = Vector2()

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = true
			drag_start_position = event.position
			set_z_index(100)  # Bring to the top while dragging
	elif event is InputEventMouseButton and not event.pressed:
		is_dragging = false
		set_z_index(0)  # Reset z-index after dropping
		
		# Notify the grid container of the drop
		var grid_container = get_parent().get_parent()  # Assuming the parent of this item's parent is the GridContainer
		if grid_container and grid_container.has_method("drop_item"):
			grid_container.drop_item(self)

func _process(delta):
	if is_dragging:
		position = get_global_mouse_position() - drag_start_position
