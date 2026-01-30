extends Node

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		_on_escape_pressed()

func _on_escape_pressed():
	print("Pause")
	get_tree().paused = true
	$PauseMenu.show()
