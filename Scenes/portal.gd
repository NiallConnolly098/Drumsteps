extends Area2D  # Changed from RigidBody2D to Area2D for better portal detection

var connected_portal = null
var global_node = null
var cell_size = 64.0

func _ready():
	add_to_group("portals")
	print("Portal ready!")
	if global_node:
		print("Global node found: ", global_node)
	else:
		print("Global node not found!")

func _on_body_entered(body):
	if body.name.begins_with("SimulationBall") and connected_portal:
		# Only handle teleportation if we're the closer portal
		var distance_to_this = (body.position - position).length()
		var distance_to_other = (body.position - connected_portal.position).length()
		
		if distance_to_this < distance_to_other:
			print("Teleporting ball from ", position, " to ", connected_portal.position)
			body.teleport_to(connected_portal.position)
