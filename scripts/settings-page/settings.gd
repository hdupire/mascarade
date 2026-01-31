extends Node2D

signal back_pressed
signal option_selected(option_index: int)

var screen_size: Vector2

func _ready():
	screen_size = get_viewport().get_visible_rect().size
	_setup_background()
	_setup_clickable_zones()

func _load_texture_from_file(path: String) -> ImageTexture:
	var abs_path = ProjectSettings.globalize_path(path)
	var image = Image.new()
	var err = image.load(abs_path)
	if err != OK:
		return null
	return ImageTexture.create_from_image(image)

func _setup_background():
	var bg_tex = _load_texture_from_file("res://assets/png/settings-bg.png")
	if bg_tex:
		var bg = Sprite2D.new()
		bg.texture = bg_tex
		bg.centered = false
		bg.scale = screen_size / bg_tex.get_size()
		add_child(bg)

func _setup_clickable_zones():
	var zone_width = 400.0
	var zone_height = 80.0
	var center_x = screen_size.x / 2
	
	_create_clickzone(Vector2(center_x, screen_size.y * 0.30), Vector2(zone_width, zone_height), 0)
	_create_clickzone(Vector2(center_x, screen_size.y * 0.48), Vector2(zone_width, zone_height), 1)
	_create_clickzone(Vector2(center_x, screen_size.y * 0.65), Vector2(zone_width, zone_height), 2)

func _create_clickzone(pos: Vector2, size: Vector2, index: int):
	var area = Area2D.new()
	area.position = pos
	add_child(area)
	
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	area.add_child(collision)
	
	area.input_event.connect(func(_vp, event, _idx): _on_zone_clicked(event, index))

func _on_zone_clicked(event, index: int):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("option_selected", index)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("back_pressed")
