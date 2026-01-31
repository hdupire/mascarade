extends Node

var current_scene : Node

func _ready() -> void:
	load_menu()

func load_menu() -> void:
	_change_scene("res://scenes/main-menu/main-menu.tscn")

func load_game() -> void:
	_change_scene("res://scenes/game/Mascarade.tscn")

func load_masks() -> void:
	_change_scene("res://scenes/masks-page/masks-page.tscn")

func load_powerups() -> void:
	_change_scene("res://scenes/powerup-page/powerup-page.tscn")

func load_settings() -> void:
	_change_scene("res://scenes/settings-page/settings-page.tscn")

func _change_scene(path) -> void:
	if current_scene:
		current_scene.queue_free()

	current_scene = load(path).instantiate()
	add_child(current_scene)
	
	if current_scene.has_signal("play_pressed"):
		current_scene.play_pressed.connect(load_game)
	
	if current_scene.has_signal("open_masks"):
		current_scene.open_masks.connect(load_masks)
	
	if current_scene.has_signal("open_powerups"):
		current_scene.open_powerups.connect(load_powerups)
	
	if current_scene.has_signal("open_settings"):
		current_scene.open_settings.connect(load_settings)
	
	if current_scene.has_signal("back_pressed"):
		current_scene.back_pressed.connect(load_menu)
