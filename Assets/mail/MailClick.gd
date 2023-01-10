extends Area2D

signal clicked

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		emit_signal("clicked")
