extends TextureRect

@export var snap_size_x := 64
@export var snap_size_y := 64
var is_dragging = false
var is_hovered = false

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and is_hovered:
			is_dragging = true
		else:
			is_dragging = false
			snap_to_grid()
	if is_dragging and event is InputEventMouseMotion:
		global_position += event.relative

func snap_to_grid():
	# Snap the TextureRect's position to the nearest grid cell
	var snap_size = Vector2(snap_size_x, snap_size_y)
	global_position = global_position.snapped(snap_size)

func _on_mouse_entered():
	is_hovered = true

func _on_mouse_exited():
	is_hovered = false
