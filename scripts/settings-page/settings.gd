extends Node2D

signal back_pressed

var screen_size: Vector2
var title_sprite: Sprite2D
var mute_btn: Sprite2D
var language_btn: Sprite2D
var exit_btn: Sprite2D

var is_muted: bool = false
var language_selected: bool = false

func _ready():
	screen_size = get_viewport().get_visible_rect().size
	_setup_background()
	_setup_ui()

func _load_texture_from_file(path: String) -> ImageTexture:
	var abs_path = ProjectSettings.globalize_path(path)
	var image = Image.new()
	var err = image.load(abs_path)
	if err != OK:
		return null
	return ImageTexture.create_from_image(image)

func _setup_background():
	var bg_tex = _load_texture_from_file("res://assets/png/menu-bg-settings.png")
	if bg_tex:
		var bg = Sprite2D.new()
		bg.texture = bg_tex
		bg.centered = false
		bg.scale = screen_size / bg_tex.get_size()
		add_child(bg)

func _setup_ui():
	var center_x = screen_size.x / 2
	var start_y = 80
	var spacing = 20
	
	var title_tex = _load_texture_from_file("res://assets/png/menu-title-settings.png")
	if title_tex:
		title_sprite = Sprite2D.new()
		title_sprite.texture = title_tex
		title_sprite.position = Vector2(center_x, start_y)
		add_child(title_sprite)
		start_y += title_tex.get_size().y / 2 + spacing
	
	var mute_tex = _load_texture_from_file("res://assets/png/menu-btn-settings-mute.png")
	if mute_tex:
		start_y += mute_tex.get_size().y / 2
		mute_btn = Sprite2D.new()
		mute_btn.texture = mute_tex
		mute_btn.position = Vector2(center_x, start_y)
		add_child(mute_btn)
		start_y += mute_tex.get_size().y / 2 + spacing
	
	var lang_tex = _load_texture_from_file("res://assets/png/menu-btn-settings-language.png")
	if lang_tex:
		start_y += lang_tex.get_size().y / 2
		language_btn = Sprite2D.new()
		language_btn.texture = lang_tex
		language_btn.position = Vector2(center_x, start_y)
		add_child(language_btn)
		start_y += lang_tex.get_size().y / 2 + spacing
	
	var exit_tex = _load_texture_from_file("res://assets/png/menu-btn-settings-exit.png")
	if exit_tex:
		start_y += exit_tex.get_size().y / 2
		exit_btn = Sprite2D.new()
		exit_btn.texture = exit_tex
		exit_btn.position = Vector2(center_x, start_y)
		add_child(exit_btn)

func _process(_delta):
	_update_hover_effects()

func _update_hover_effects():
	var mouse_pos = get_viewport().get_mouse_position()
	
	if title_sprite:
		title_sprite.modulate = Color(1.3, 1.3, 1.3) if _is_point_in_sprite(mouse_pos, title_sprite) else Color.WHITE
	if mute_btn:
		var base = Color(0.6, 0.6, 0.6) if is_muted else Color.WHITE
		mute_btn.modulate = Color(base.r * 1.3, base.g * 1.3, base.b * 1.3) if _is_point_in_sprite(mouse_pos, mute_btn) else base
	if language_btn:
		var base = Color(0.8, 0.8, 1.0) if language_selected else Color.WHITE
		language_btn.modulate = Color(base.r * 1.3, base.g * 1.3, base.b * 1.3) if _is_point_in_sprite(mouse_pos, language_btn) else base
	if exit_btn:
		exit_btn.modulate = Color(1.3, 1.3, 1.3) if _is_point_in_sprite(mouse_pos, exit_btn) else Color.WHITE

func _is_point_in_sprite(point: Vector2, sprite: Sprite2D) -> bool:
	if not sprite or not sprite.texture:
		return false
	var tex_size = sprite.texture.get_size()
	var rect = Rect2(sprite.position - tex_size / 2, tex_size)
	return rect.has_point(point)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("back_pressed")
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = event.position
		
		if title_sprite and _is_point_in_sprite(mouse_pos, title_sprite):
			print("Settings title clicked - returning to menu")
			emit_signal("back_pressed")
			return
		
		if mute_btn and _is_point_in_sprite(mouse_pos, mute_btn):
			is_muted = not is_muted
			print("Mute toggled: ", is_muted)
			AudioServer.set_bus_mute(0, is_muted)
			return
		
		if language_btn and _is_point_in_sprite(mouse_pos, language_btn):
			language_selected = not language_selected
			print("Language toggled: ", language_selected)
			return
		
		if exit_btn and _is_point_in_sprite(mouse_pos, exit_btn):
			print("Exit clicked - quitting game")
			get_tree().quit()
			return
