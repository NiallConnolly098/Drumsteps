extends Area2D

@export var fall_speed = 200  # Speed at which the ball falls
@export var collision_sound: AudioStream  # Sound to play on collision

var is_simulating = false  # Whether the simulation is active
var dragging = false

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
	if dragging and event is InputEventMouseMotion:
		global_position += event.relative

func _process(delta):
	if is_simulating:
		# Move the ball downward during simulation
		position.y += fall_speed

func start_simulation():
	# Called to start the simulation
	is_simulating = true

func stop_simulation():
	# Called to stop the simulation
	is_simulating = false

	# Reset the position to its initial state (optional)
	# This assumes you have a stored initial position
	global_position = Vector2()

func _on_area_entered(area):
	# Play the collision sound when hitting a step
	if collision_sound and area.is_in_group("steps"):
		var audio_player = AudioStreamPlayer2D.new()
		add_child(audio_player)
		audio_player.stream = collision_sound
		audio_player.play()
		audio_player.queue_free()  # Clean up after the sound plays

