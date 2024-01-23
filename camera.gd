extends Camera2D


var dragging := false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		dragging = event.pressed
	if dragging and event is InputEventMouseMotion:
		position -= event.relative
