extends Area2D

# signal portal_clicked(portal)

func _ready():
	pass

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		# Emit a signal with a reference to the portal
		emit_signal("portal_clicked", get_parent())
