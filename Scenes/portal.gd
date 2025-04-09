extends RigidBody2D

var is_entrance = true  # True for entrance portal, False for exit portal
var connected_portal = null
var global_node = null

func _ready():
	print("Portal ready!")
	if global_node:
		print("Global node found: ", global_node)
	else:
		print("Global node not found!")

func _on_body_entered(body):
	if body.name.begins_with("SimulationBall") and connected_portal:
		body.position = connected_portal.position
		print("Ball teleported from ", position, " to ", connected_portal.position)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
			# Emit a signal with a reference to the portal
			emit_signal("portal_clicked", get_parent())
