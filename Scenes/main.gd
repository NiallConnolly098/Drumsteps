extends Node2D

# Preload the setup and simulation scenes
@export var setup_ball_scene: PackedScene = preload("res://Scenes/SetupBall.tscn")
@export var setup_step_scene: PackedScene = preload("res://Scenes/SetupStep.tscn")
@export var simulation_ball_scene: PackedScene = preload("res://Scenes/SimulationBall.tscn")
@export var simulation_step_scene: PackedScene = preload("res://Scenes/SimulationStep.tscn")

var cell_size = 64.0
var grid_width = 30
var grid_height = 16

# Variables to track dragging
var is_dragging = false
var current_dragged_object = null

var occupied_cells = {}

func _ready():
	 # Connect the PlayButton signal using Callable
	$PlayButton.pressed.connect(_on_PlayButton_pressed)


func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			# Check if the touch is on the BallButton or StepButton
			if $TopBar/BallButton.get_rect().has_point(event.position):
				current_dragged_object = setup_ball_scene.instantiate()
			elif $TopBar/StepButton.get_rect().has_point(event.position):
				current_dragged_object = setup_step_scene.instantiate()
			else:
				# Check if the touch is on an existing object in the grid
				for child in $Grid.get_children():
					if child.has_node("Sprite2D"):
						var sprite = child.get_node("Sprite2D")
						var object_size = sprite.texture.get_size()
						var object_position = child.global_position
						
						var object_rect = Rect2(
							object_position - object_size / 2,
							object_size
						)
						if object_rect.has_point(event.position):
							current_dragged_object = child
							var cell_key = get_cell_key(current_dragged_object.position)
							if occupied_cells.has(cell_key):
								occupied_cells.erase(cell_key)
								print("Picked up object from cell: ", cell_key)
							break
			
			if current_dragged_object:
				if current_dragged_object.get_parent() == null:
					add_child(current_dragged_object)
				current_dragged_object.position = event.position
				is_dragging = true
				print("Started dragging object: ", current_dragged_object.name)
		else:
			# Stop dragging when the user releases the touch
			if is_dragging and current_dragged_object:
				if $Grid.get_rect().has_point(event.position):
					# Add the object to the grid
					var snapped_position = snap_to_grid(event.position)
					if snapped_position != null:
						current_dragged_object.position = snapped_position
						if current_dragged_object.get_parent() != $Grid:
							current_dragged_object.get_parent().remove_child(current_dragged_object)
							$Grid.add_child(current_dragged_object)
						print("Dropped object at cell: ", get_cell_key(snapped_position))
					else:
						current_dragged_object.queue_free()
						print("Cannot place object: Cell occupied")
				else:
					# Remove the object if it's not over the grid
					current_dragged_object.queue_free()
					print("Object removed: Not over grid")
					
				is_dragging = false
				current_dragged_object = null

	elif event is InputEventScreenDrag and is_dragging:
		# Move the dragged object with the touch
		if current_dragged_object:
			current_dragged_object.position += event.relative

func _on_PlayButton_pressed():
	# Replace setup objects with simulation objects
	for child in $Grid.get_children():
		var new_object = null
		if child.name == "SetupBall":
			new_object = simulation_ball_scene.instantiate()
		elif child.name == "SetupStep":
			new_object = simulation_step_scene.instantiate()
		
		if new_object:
			new_object.position = child.position
			$Grid.add_child(new_object)
			child.queue_free()

func snap_to_grid(touch_position):
	# Convert the global position to the grid's local coordinates
	var local_position = $Grid.get_global_transform().affine_inverse() * touch_position
	
	print("Local position: ", local_position)
	# Snap to the nearest grid cell
	var snapped_x = floor(local_position.x / cell_size) * cell_size
	var snapped_y = floor(local_position.y / cell_size) * cell_size
	
	print("Snapped position (local): ", Vector2(snapped_x, snapped_y))
	# Convert the snapped position back to global coordinates
	var snapped_position = $Grid.position + Vector2(snapped_x + 32, snapped_y - 32)
	
	print("Snapped position (global): ", snapped_position)
	
	var cell_key = get_cell_key(snapped_position)
	if occupied_cells.has(cell_key):
		return null
	else:
		occupied_cells[cell_key] = current_dragged_object
		return snapped_position

func get_cell_key(pos):
	var local_position = $Grid.get_global_transform().affine_inverse() * pos
	return Vector2(round(local_position.x / cell_size), round(local_position.y / cell_size))
