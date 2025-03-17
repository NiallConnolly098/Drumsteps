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
		position = Vector2(grid_position.x * cell_size, grid_position.y * cell_size)
		print("Moved right to: ", grid_position)
		$Timer.start()
		check_for_steps()

func move_down():
	if is_moving:
		grid_position.y += 1
		position = Vector2(grid_position.x * cell_size, grid_position.y * cell_size)
		print("Moved down to: ", grid_position)
		$Timer.start()
		check_for_steps()

func check_for_steps():
	if is_moving and global_node:
		var cell_below = Vector2(grid_position.x, grid_position.y + 1)
		print("Checking cell below: ", cell_below)
		if global_node.occupied_cells.has(cell_below) and (sound_played == false):
			$AudioStreamPlayer2D.play()
			sound_played = true
			move_right()
		elif global_node.occupied_cells.has(cell_below) and (sound_played == true):
			move_right()
		else:
			sound_played = false
			move_down()

func start_movement():
	is_moving = true
	$Timer.start()
	check_for_steps()

func _on_timer_timeout() -> void:
	check_for_steps()
