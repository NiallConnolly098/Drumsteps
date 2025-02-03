extends Node2D

var ball_scene = preload("res://Scenes/ball.tscn")
var step_scene = preload("res://Scenes/step.tscn")

var is_dragging = false
var current_dragged_object = null


func _ready() -> void:
	$PlayButton.pressed.connect(_on_PlayButton_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			# Check if the touch is on the BallButton or StepButton
			if $TopBar/BallButton.get_rect().has_point(event.position):
				current_dragged_object = ball_scene.instantiate()
			elif $TopBar/StepButton.get_rect().has_point(event.position):
				current_dragged_object = step_scene.instantiate()
			if current_dragged_object:
				current_dragged_object.position = event.position
				add_child(current_dragged_object)
			is_dragging = true
		else:
			# Stop dragging when the user releases the touch
			if is_dragging and current_dragged_object:
				if $Grid.get_rect().has_point(event.position):
					# Add the object to the grid
					$Grid.add_child(current_dragged_object)
					current_dragged_object.position = event.position - $Grid.position
				else:
					# Remove the object if it's not over the grid
					current_dragged_object.queue_free()
					
				is_dragging = false
				current_dragged_object = null
	
	elif event is InputEventScreenDrag and is_dragging:
		# Move the dragged object with the touch
		if current_dragged_object:
			current_dragged_object.position += event.relative

func _on_PlayButton_pressed():
	# Enable physics for all balls in the grid
	for child in $Grid.get_children():
		if child is RigidBody2D:
			child.gravity_scale = 1.0
