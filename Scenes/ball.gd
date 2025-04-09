extends RigidBody2D

var cell_size = 64
var grid_position = Vector2(0, 0)
var is_moving = false

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

func check_for_steps():
	if is_moving and global_node:
		var cell_below = Vector2(grid_position.x, grid_position.y)
		var top_cell = Vector2(grid_position.x, -1)
		print("Checking cell below: ", cell_below)
		print("Occupied cells: ", global_node.occupied_cells)
		if global_node.occupied_cells.has(cell_below):
			print("Step detected at: ", cell_below)
			if not sound_played:
				$AudioStreamPlayer2D.play()
				sound_played = true
			if cell_below == Vector2(30, grid_position.y):
				loop_horizontal()
			else: move_right()
		elif cell_below == Vector2(grid_position.x, 16):
			if global_node.occupied_cells.has(top_cell):
				if not sound_played:
					$AudioStreamPlayer2D.play()
					sound_played = true
				if cell_below == Vector2(30, grid_position.y):
					loop_horizontal()
				else: move_right()
			else:
				print("Looping")
				sound_played = false
				loop_vertical()
		else:
			print("No step detected, moving down")
			sound_played = false
			move_down()

func start_movement():
	print("Starting movement")
	is_moving = true
	check_for_steps()

func _on_timer_timeout() -> void:
	check_for_steps()
