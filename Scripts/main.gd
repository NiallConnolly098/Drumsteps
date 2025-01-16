extends Control

@export var ball_scene: PackedScene
@export var step_scene: PackedScene

func _on_play_button_pressed():
	# Get all children of the grid
	var grid = $Grid
	for node in grid.get_children():
		if node is TextureRect:
			replace_with_physics_node(node)

func replace_with_physics_node(texture_rect):
	var new_instance

	# Determine whether to replace with a ball or a step
	if texture_rect.name == "Ball":
		new_instance = ball_scene.instantiate()
	elif texture_rect.name == "Step":
		new_instance = step_scene.instantiate()
	else:
		return  # Ignore other nodes

	# Position the new instance where the TextureRect was
	new_instance.global_position = texture_rect.global_position

	# Add the new instance to the grid's parent (or appropriate container)
	texture_rect.get_parent().add_child(new_instance)

	# Remove the original TextureRect
	texture_rect.queue_free()
	

func reset_simulation():
	var grid = $Grid  # Replace with your grid node path
	for node in grid.get_children():
		node.queue_free()

	# Recreate the TextureRects in their initial positions
	create_initial_items()

func create_initial_items():
	var grid = $Grid  # Replace with your grid node path
	# Add TextureRects back to the grid with their initial positions
	var ball_texture = preload("res://Media/Art/Ball.png")
	var step_texture = preload("res://Media/Art/Step.png")

	var ball = TextureRect.new()
	ball.texture = ball_texture
	ball.global_position = Vector2(100, 100)  # Adjust as needed
	ball.name = "Ball"
	grid.add_child(ball)

	var step = TextureRect.new()
	step.texture = step_texture
	step.global_position = Vector2(200, 200)  # Adjust as needed
	step.name = "Step"
	grid.add_child(step)
