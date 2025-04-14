extends Node2D

# Preload the setup and simulation scenes
@export var setup_ball_scene: PackedScene = preload("res://Scenes/SetupBall.tscn")
@export var setup_step_scene: PackedScene = preload("res://Scenes/SetupStep.tscn")
@export var simulation_ball_scene: PackedScene = preload("res://Scenes/SimulationBall.tscn")
@export var simulation_step_scene: PackedScene = preload("res://Scenes/SimulationStep.tscn")
@export var portal: PackedScene = preload("res://Scenes/portal.tscn")

@onready var portal_connector = $PortalConnector

var play_pressed = false

var cell_size = 64.0
var grid_width = 30
var grid_height = 16

var is_dragging = false
var current_dragged_object = null

var portal_connection_mode = false
var first_portal_selected = null
var second_portal_selected = null

var global_node

func _ready():
	global_node = get_node("Global")

func _input(event):
	if portal_connection_mode and event is InputEventScreenTouch and event.pressed:
		# Check for portal selection only in connection mode
		for child in $Grid.get_children():
			if child.name.begins_with("Portal_"):
				var sprite = child.get_node("Sprite2D")
				var object_rect = Rect2(
					child.global_position - sprite.texture.get_size() / 2,
					sprite.texture.get_size()
				)
				if object_rect.has_point(event.position):
					if first_portal_selected == null:
						first_portal_selected = child
						child.modulate = Color(0.5, 1, 0.5) # Green highlight
						print("First portal selected")
					elif first_portal_selected != child:
						first_portal_selected.connected_portal = child
						child.connected_portal = first_portal_selected
						portal_connector.portals.append(first_portal_selected)
						portal_connector.portals.append(child)
						first_portal_selected.modulate = Color(1, 1, 1)
						child.modulate = Color(1, 1, 1)
						print("Connected portals")
						first_portal_selected = null
					return
		if first_portal_selected:
			first_portal_selected.modulate = Color(1,1,1)
			first_portal_selected = null
		return
	
	if event is InputEventScreenTouch:
		if event.pressed:
			# Check if the touch is on the BallButton or StepButton
			if $TopBar/BallButton.get_rect().has_point(event.position):
				current_dragged_object = setup_ball_scene.instantiate()
				current_dragged_object.name = "SetupBall_%d" % $Grid.get_child_count()
				print("New Ball Created")
			elif $TopBar/StepButton.get_rect().has_point(event.position):
				current_dragged_object = setup_step_scene.instantiate()
				current_dragged_object.name = "SetupStep_%d" % $Grid.get_child_count()
				print("New SetupStep Created")
			elif $TopBar/PortalButton.get_rect().has_point(event.position):
				current_dragged_object = portal.instantiate()
				current_dragged_object.name = "Portal_%d" % $Grid.get_child_count()
				print("New Portal Created")
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
							if global_node.occupied_cells.has(cell_key):
								global_node.occupied_cells.erase(cell_key)
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
					var result = snap_to_grid(event.position)
					var snapped_position = result["snapped_position"]
					var cell_key = result["cell_key"]
					
					if snapped_position != null:
						current_dragged_object.position = snapped_position
						if current_dragged_object.get_parent() != $Grid:
							current_dragged_object.get_parent().remove_child(current_dragged_object)
							$Grid.add_child(current_dragged_object)
							
						if current_dragged_object.name.begins_with("SetupStep"):
							global_node.occupied_cells[cell_key] = true
							print("Occupied cells: ", global_node.occupied_cells)
							print("Step placed at cell: ", cell_key)
						print("Dropped object at cell: ", cell_key)
						
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
	return {"snapped_position": snapped_position, "cell_key": cell_key}

func get_cell_key(pos):
	var local_position = $Grid.get_global_transform().affine_inverse() * pos
	return Vector2(round(local_position.x / cell_size), round(local_position.y / cell_size))

func _on_play_button_pressed():
	if !play_pressed:
		play_pressed = true
		print("Play button pressed")
		print("Number of children in $Grid: ", $Grid.get_child_count())
		var new_objects = []
		
		for child in $Grid.get_children():
			print("Child name: ", child.name)
			var new_object = null
			
			if child.name.begins_with("SetupBall"):
				new_object = simulation_ball_scene.instantiate()
				new_object.global_node = $Global
				new_object.position = child.position
				new_object.name = "SimulationBall_%d" % new_objects.size()
				print("Replaced SetupBall with SimulationBall at position: ", child.position)
			
			elif child.name.begins_with("SetupStep"):
				new_object = simulation_step_scene.instantiate()
				new_object.global_node = $Global
				new_object.position = child.position
				new_object.name = "SimulationStep_%d" % new_objects.size()
				print("Replaced SetupStep with SimulationStep at position: ", child.position)
			
			elif child.name.begins_with("Portal_"):
				new_object = child  # Keep the same portal
				new_object.global_node = $Global
				print("Portal maintained: ", child.name)
			
			if new_object:
				new_objects.append(new_object)
				if child != new_object:
					child.queue_free()
		
		for child in $Grid.get_children():
			if not child.name.begins_with("Portal_"):
				child.queue_free()
		
		for new_object in new_objects:
			if new_object.get_parent() != $Grid:
				$Grid.add_child(new_object)
			if new_object.name.begins_with("SimulationBall"):
				new_object.start_movement()

func _on_menu_button_pressed() -> void:
	get_tree().quit()

func _on_button_pressed() -> void:
	play_pressed = false
	get_tree().reload_current_scene()

func _on_portal_connect_button_pressed():
	portal_connection_mode = !portal_connection_mode
	if portal_connection_mode:
		print("Portal connection mode activated")
	else:
		print("Portal connection mode deactivated")
		first_portal_selected = null
		second_portal_selected = null
