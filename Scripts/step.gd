extends StaticBody2D

@export var is_movable = true  # Steps can optionally be made draggable

func _ready():
	# Set the step in the "steps" group for collision detection
	add_to_group("steps")

func start_simulation():
	# Lock the step in place if it was movable
	is_movable = false

func stop_simulation():
	# Allow the step to be moved again (optional)
	is_movable = true

func _input(event):
	# If the step is draggable, allow drag-and-drop
	if is_movable and event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		global_position += event.relative
