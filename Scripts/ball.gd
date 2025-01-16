extends Area2D

@export var fall_speed = 40
@export var collision_sound: AudioStream

var is_simulating = false

func start_simulation():
	is_simulating = true

func _physics_process(delta):
	if is_simulating:
		position.y += fall_speed
