extends Node

var current_scene : Node

func _ready() -> void:
	load_menu()

func load_menu() -> void:
	_change_scene("res://scenes/main-menu/main-menu.tscn")

func load_game() -> void:
	_change_scene("res://scenes/game/Mascarade.tscn")

func _change_scene(path) -> void:
	if current_scene:
		current_scene.queue_free()

	current_scene = load(path).instantiate()
	add_child(current_scene)
	
	if current_scene.has_signal("play_pressed"):
		current_scene.play_pressed.connect(load_game)
