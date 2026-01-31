extends Node2D

signal back_pressed

var screen_size: Vector2
var title_sprite: Sprite2D

func _ready():
	screen_size = get_viewport().get_visible_rect().size
	_setup_background()
	_setup_title()

func _load_texture_from_file(path: String) -> ImageTexture:
	var abs_path = ProjectSettings.globalize_path(path)
	var image = Image.new()
	var err = image.load(abs_path)
	if err != OK:
		return null
	return ImageTexture.create_from_image(image)

func _setup_background():
	var bg_tex = _load_texture_from_file("res://assets/png/menu-bg-mask.png")
	if bg_tex:
		var bg = Sprite2D.new()
		bg.texture = bg_tex
		bg.centered = false
		bg.scale = screen_size / bg_tex.get_size()
		add_child(bg)

func _setup_title():
	var title_tex = _load_texture_from_file("res://assets/png/menu-title-mask.png")
	if title_tex:
		title_sprite = Sprite2D.new()
		title_sprite.texture = title_tex
		title_sprite.centered = false
		title_sprite.position = Vector2(0, 0)
		add_child(title_sprite)
	
	var trophees_tex = _load_texture_from_file("res://assets/png/menu-trophees-mask.png")
	if trophees_tex:
		var trophees = Sprite2D.new()
		trophees.texture = trophees_tex
		trophees.position = Vector2(screen_size.x / 2, screen_size.y / 2)
		add_child(trophees)

func _process(_delta):
	if title_sprite:
		var mouse_pos = get_viewport().get_mouse_position()
		title_sprite.modulate = Color(1.3, 1.3, 1.3) if _is_point_in_title(mouse_pos) else Color.WHITE

func _is_point_in_title(point: Vector2) -> bool:
	if not title_sprite or not title_sprite.texture:
		return false
	var tex_size = title_sprite.texture.get_size()
	var rect = Rect2(title_sprite.position, tex_size)
	return rect.has_point(point)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("back_pressed")
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if _is_point_in_title(event.position):
			print("Masks title clicked - returning to menu")
			emit_signal("back_pressed")
