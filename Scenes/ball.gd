extends RigidBody2D

var cell_size = 64
var grid_position = Vector2(0, 0)
var is_moving = false

var last_portal_entered = null

var global_node = null
var sound_played = false

func _ready() -> void:
	print("SimulationBall ready!")
	if global_node:
		print("Global node found: ", global_node)
	else:
		print("Global node not found!")
	snap_to_grid()

func snap_to_grid():
	grid_position = Vector2(round(position.x / cell_size), round(position.y / cell_size))
	position = Vector2(grid_position.x * cell_size -32, grid_position.y * cell_size -32)
	print("Ball snapped to grid position: ", grid_position)

func move_right():
	if is_moving:
		grid_position.x += 1
		position = Vector2(grid_position.x * cell_size -32, grid_position.y * cell_size -32)
		print("Moved right to: ", grid_position)
		%CheckForSteps.start()

func move_down():
	if is_moving:
		grid_position.y += 1
		position = Vector2(grid_position.x * cell_size -32, grid_position.y * cell_size -32)
		print("Moved down to: ", grid_position)
		%CheckForSteps.start()

func loop_vertical():
	if is_moving:
		grid_position.y = 1
		position = Vector2(grid_position.x * cell_size -32, grid_position.y * cell_size -32)
		print("Moved down to: ", grid_position)
		%CheckForSteps.start()

func loop_horizontal():
	if is_moving:
		grid_position.x = 1
		position = Vector2(grid_position.x * cell_size -32, grid_position.y * cell_size -32)
		print("Moved down to: ", grid_position)
		%CheckForSteps.start()

func teleport_to(new_position):
	position = new_position
	grid_position = Vector2(round(new_position.x / cell_size), round(new_position.y / cell_size))
	sound_played = false
	print("Ball teleported to: ", grid_position)
	# Immediately continue movement
	%CheckForSteps.start()

func check_for_steps():
	if not is_moving or not global_node:
		return
	
	for portal in get_tree().get_nodes_in_group("portals"):
		if portal.connected_portal and portal != last_portal_entered:
			var portal_grid_pos = Vector2(
				round(portal.position.x / cell_size), 
				round(portal.position.y / cell_size)
			)
			if grid_position == portal_grid_pos:
				last_portal_entered = portal.connected_portal  # Set to destination portal
				teleport_to(portal.connected_portal.position)
				return
	
	# Reset portal tracking if not on a portal
	last_portal_entered = null
	
	# Original step checking logic
	var cell_below = Vector2(grid_position.x, grid_position.y)
	var top_cell = Vector2(grid_position.x, -1)
	
	if global_node.occupied_cells.has(cell_below):
		if not sound_played:
			$AudioStreamPlayer2D.play()
			sound_played = true
		if cell_below == Vector2(30, grid_position.y):
			loop_horizontal()
		else: 
			move_right()
	elif cell_below == Vector2(grid_position.x, 16):
		if global_node.occupied_cells.has(top_cell):
			if not sound_played:
				$AudioStreamPlayer2D.play()
				sound_played = true
			if cell_below == Vector2(30, grid_position.y):
				loop_horizontal()
			else: 
				move_right()
		else:
			sound_played = false
			loop_vertical()
	else:
		sound_played = false
		move_down()

func start_movement():
	print("Starting movement")
	is_moving = true
	check_for_steps()

func _on_timer_timeout() -> void:
	check_for_steps()
