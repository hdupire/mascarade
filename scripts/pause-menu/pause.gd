extends Control

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == Key.KEY_ESCAPE:
			print("Hello")
			accept_event()
			_unpause()

func _unpause() -> void:
	self.hide()
	get_tree().paused = false
