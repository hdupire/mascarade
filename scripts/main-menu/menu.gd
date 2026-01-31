extends Node2D

signal play_pressed
signal join_game(code: String)
signal open_masks
signal open_powerups
signal open_settings

var tournament_code: String = ""
var game_btn_size: Vector2 = Vector2.ZERO
var new_game_zone: Rect2
var join_zone: Rect2
const CODE_CHARACTERS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"

const CREAM = Color(0.95, 0.9, 0.8)

var screen_size: Vector2
var custom_font: Font

var logo_sprite: Sprite2D
var game_btn_sprite: Sprite2D
var settings_btn_sprite: Sprite2D
var mask_btn: RigidBody2D
var powerup_btn: RigidBody2D

var code_input: LineEdit

var logo_wiggle_timer: float = 0.0
var logo_wiggle_interval: float = 5.0
var logo_is_wiggling: bool = false
var logo_wiggle_time: float = 0.0

var settings_spin_timer: float = 0.0
var settings_spin_interval: float = 4.0
var settings_is_spinning: bool = false
var settings_spin_progress: float = 0.0

var game_btn_bob_offset: float = 0.0

func _ready():
		screen_size = get_viewport().get_visible_rect().size
		custom_font = _load_font_from_file()
		_setup_background()
		_setup_logo()
		_setup_settings_button()
		_setup_game_button()
		_setup_floating_buttons()
		_setup_screen_walls()

func _load_font_from_file() -> Font:
		var font_path = ProjectSettings.globalize_path("res://assets/font/NEWTONIN.OTF")
		if FileAccess.file_exists(font_path):
				var font = FontFile.new()
				font.load_dynamic_font(font_path)
				return font
		return null

func _load_texture_from_file(path: String) -> ImageTexture:
		var abs_path = ProjectSettings.globalize_path(path)
		var image = Image.new()
		var err = image.load(abs_path)
		if err != OK:
				push_error("Failed to load image: " + path)
				return null
		var texture = ImageTexture.create_from_image(image)
		return texture

func _setup_background():
		var bg_tex = _load_texture_from_file("res://assets/png/menu-bg.png")
		if bg_tex:
				var bg = Sprite2D.new()
				bg.texture = bg_tex
				bg.centered = false
				bg.scale = screen_size / bg_tex.get_size()
				add_child(bg)
		else:
				var bg = ColorRect.new()
				bg.color = Color(0.15, 0.1, 0.05)
				bg.size = screen_size
				add_child(bg)

func _setup_logo():
		var logo_tex = _load_texture_from_file("res://assets/png/menu-logo.png")
		if logo_tex:
				logo_sprite = Sprite2D.new()
				logo_sprite.texture = logo_tex
				logo_sprite.position = Vector2(screen_size.x / 2, screen_size.y * 0.4)
				add_child(logo_sprite)

func _setup_settings_button():
		var settings_tex = _load_texture_from_file("res://assets/png/menu-btn-settings.png")
		if settings_tex:
				settings_btn_sprite = Sprite2D.new()
				settings_btn_sprite.texture = settings_tex
				settings_btn_sprite.position = Vector2(screen_size.x * 0.9, screen_size.y * 0.1)
				add_child(settings_btn_sprite)
				
				var area = Area2D.new()
				area.position = Vector2.ZERO
				area.input_pickable = true
				area.monitorable = true
				area.monitoring = true
				settings_btn_sprite.add_child(area)
				
				var collision = CollisionShape2D.new()
				var shape = RectangleShape2D.new()
				shape.size = settings_tex.get_size() + Vector2(10, 10)
				collision.shape = shape
				area.add_child(collision)
				
				area.input_event.connect(_on_settings_clicked)
				area.mouse_entered.connect(func(): settings_btn_sprite.modulate = Color(1.3, 1.3, 1.3))
				area.mouse_exited.connect(func(): settings_btn_sprite.modulate = Color.WHITE)

func _setup_game_button():
		var game_tex = _load_texture_from_file("res://assets/png/menu-btn-game.png")
		if game_tex:
				game_btn_sprite = Sprite2D.new()
				game_btn_sprite.texture = game_tex
				game_btn_sprite.position = Vector2(screen_size.x / 2, screen_size.y * 0.65)
				add_child(game_btn_sprite)
				game_btn_size = game_tex.get_size()
				
				var btn_top_left = game_btn_sprite.position - game_btn_size / 2
				new_game_zone = Rect2(btn_top_left.x + 100 - 100, btn_top_left.y + 170 - 30, 200, 60)
				join_zone = Rect2(btn_top_left.x + 340 - 100, btn_top_left.y + 170 - 30, 200, 60)
		
		_setup_code_input()

func _setup_code_input():
		var ui_layer = CanvasLayer.new()
		add_child(ui_layer)
		
		var container = Control.new()
		container.set_anchors_preset(Control.PRESET_FULL_RECT)
		container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ui_layer.add_child(container)
		
		code_input = LineEdit.new()
		code_input.placeholder_text = "CODE"
		code_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
		code_input.max_length = 4
		code_input.custom_minimum_size = Vector2(200, 50)
		code_input.add_theme_font_size_override("font_size", 36)
		if custom_font:
				code_input.add_theme_font_override("font", custom_font)
		code_input.add_theme_color_override("font_color", CREAM)
		code_input.add_theme_color_override("font_placeholder_color", Color(CREAM, 0.5))
		
		var transparent_style = StyleBoxEmpty.new()
		code_input.add_theme_stylebox_override("normal", transparent_style)
		code_input.add_theme_stylebox_override("focus", transparent_style)
		code_input.add_theme_stylebox_override("read_only", transparent_style)
		
		code_input.position = Vector2(screen_size.x / 2 - 100, screen_size.y * 0.65 - 60)
		code_input.size = Vector2(200, 50)
		code_input.mouse_filter = Control.MOUSE_FILTER_STOP
		code_input.text_changed.connect(_on_code_text_changed)
		container.add_child(code_input)

func _setup_floating_buttons():
		mask_btn = _create_floating_button("res://assets/png/menu-btn-mask.png", "mask")
		powerup_btn = _create_floating_button("res://assets/png/menu-btn-powerup.png", "powerup")
		
		if mask_btn:
				mask_btn.position = Vector2(randf_range(100, 300), randf_range(100, screen_size.y - 200))
				mask_btn.linear_velocity = Vector2(randf_range(-30, 30), randf_range(-30, 30))
		
		if powerup_btn:
				powerup_btn.position = Vector2(randf_range(screen_size.x - 300, screen_size.x - 100), randf_range(100, screen_size.y - 200))
				powerup_btn.linear_velocity = Vector2(randf_range(-30, 30), randf_range(-30, 30))

func _create_floating_button(tex_path: String, btn_name: String) -> RigidBody2D:
		var tex = _load_texture_from_file(tex_path)
		if not tex:
				return null
		
		var body = RigidBody2D.new()
		body.gravity_scale = 0
		body.linear_damp = 0.1
		body.angular_damp = 2.0
		body.physics_material_override = PhysicsMaterial.new()
		body.physics_material_override.bounce = 0.8
		body.physics_material_override.friction = 0.1
		body.name = btn_name
		add_child(body)
		
		var sprite = Sprite2D.new()
		sprite.texture = tex
		sprite.name = "Sprite"
		body.add_child(sprite)
		
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = tex.get_size() + Vector2(10, 10)
		collision.shape = shape
		body.add_child(collision)
		
		var area = Area2D.new()
		area.name = "ClickArea"
		area.input_pickable = true
		area.monitorable = true
		area.monitoring = true
		body.add_child(area)
		
		var area_collision = CollisionShape2D.new()
		var area_shape = RectangleShape2D.new()
		area_shape.size = tex.get_size() + Vector2(10, 10)
		area_collision.shape = area_shape
		area.add_child(area_collision)
		
		area.input_event.connect(func(_vp, event, _idx): _on_floating_btn_clicked(event, btn_name))
		area.mouse_entered.connect(func(): sprite.modulate = Color(1.3, 1.3, 1.3))
		area.mouse_exited.connect(func(): sprite.modulate = Color.WHITE)
		
		return body

func _setup_screen_walls():
		var wall_thickness = 50.0
		
		_create_wall(Vector2(screen_size.x / 2, -wall_thickness / 2), Vector2(screen_size.x, wall_thickness))
		_create_wall(Vector2(screen_size.x / 2, screen_size.y + wall_thickness / 2), Vector2(screen_size.x, wall_thickness))
		_create_wall(Vector2(-wall_thickness / 2, screen_size.y / 2), Vector2(wall_thickness, screen_size.y))
		_create_wall(Vector2(screen_size.x + wall_thickness / 2, screen_size.y / 2), Vector2(wall_thickness, screen_size.y))
		
		if game_btn_sprite:
				_create_static_collider(game_btn_sprite)
		if logo_sprite:
				_create_static_collider(logo_sprite)
		if settings_btn_sprite:
				_create_static_collider(settings_btn_sprite)

func _create_wall(pos: Vector2, size: Vector2):
		var body = StaticBody2D.new()
		body.position = pos
		add_child(body)
		
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = size
		collision.shape = shape
		body.add_child(collision)

func _create_static_collider(sprite: Sprite2D):
		if not sprite or not sprite.texture:
				return
		var body = StaticBody2D.new()
		body.position = sprite.position
		add_child(body)
		
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = sprite.texture.get_size() + Vector2(10, 10)
		collision.shape = shape
		body.add_child(collision)

func _process(delta):
		_update_logo_wiggle(delta)
		_update_settings_spin(delta)
		_update_game_btn_bob(delta)
		_apply_floating_forces()
		_update_hover_effects()

func _update_logo_wiggle(delta):
		logo_wiggle_timer += delta
		if logo_wiggle_timer >= logo_wiggle_interval and not logo_is_wiggling:
				logo_is_wiggling = true
				logo_wiggle_time = 0.0
				logo_wiggle_timer = 0.0
				logo_wiggle_interval = randf_range(3.0, 8.0)
		
		if logo_is_wiggling and logo_sprite:
				logo_wiggle_time += delta
				var wiggle_duration = 0.5
				if logo_wiggle_time < wiggle_duration:
						var intensity = sin(logo_wiggle_time * 40) * (1.0 - logo_wiggle_time / wiggle_duration)
						logo_sprite.rotation = intensity * 0.05
				else:
						logo_sprite.rotation = 0
						logo_is_wiggling = false

func _update_settings_spin(delta):
		settings_spin_timer += delta
		if settings_spin_timer >= settings_spin_interval and not settings_is_spinning:
				settings_is_spinning = true
				settings_spin_progress = 0.0
				settings_spin_timer = 0.0
				settings_spin_interval = randf_range(3.0, 7.0)
		
		if settings_is_spinning and settings_btn_sprite:
				settings_spin_progress += delta * 3.0
				if settings_spin_progress < 1.0:
						var eased = 1.0 - pow(1.0 - settings_spin_progress, 3)
						settings_btn_sprite.rotation = eased * TAU
				else:
						settings_btn_sprite.rotation = 0
						settings_is_spinning = false

func _update_game_btn_bob(delta):
		game_btn_bob_offset += delta
		if game_btn_sprite:
				var base_y = screen_size.y * 0.65
				game_btn_sprite.position.y = base_y + sin(game_btn_bob_offset * 1.5) * 5

func _apply_floating_forces():
		for body in [mask_btn, powerup_btn]:
				if body:
						if body.linear_velocity.length() < 20:
								body.apply_central_impulse(Vector2(randf_range(-5, 5), randf_range(-5, 5)))
						if body.linear_velocity.length() > 80:
								body.linear_velocity = body.linear_velocity.normalized() * 80

func _update_hover_effects():
		var mouse_pos = get_viewport().get_mouse_position()
		
		if settings_btn_sprite:
				if _is_point_in_sprite(mouse_pos, settings_btn_sprite):
						settings_btn_sprite.modulate = Color(1.3, 1.3, 1.3)
				else:
						settings_btn_sprite.modulate = Color.WHITE
		
		if game_btn_sprite:
				if _is_point_in_sprite(mouse_pos, game_btn_sprite):
						game_btn_sprite.modulate = Color(1.3, 1.3, 1.3)
				else:
						game_btn_sprite.modulate = Color.WHITE
		
		if mask_btn:
				var sprite = mask_btn.get_node_or_null("Sprite")
				if sprite:
						if _is_point_in_rigidbody(mouse_pos, mask_btn):
								sprite.modulate = Color(1.3, 1.3, 1.3)
						else:
								sprite.modulate = Color.WHITE
		
		if powerup_btn:
				var sprite = powerup_btn.get_node_or_null("Sprite")
				if sprite:
						if _is_point_in_rigidbody(mouse_pos, powerup_btn):
								sprite.modulate = Color(1.3, 1.3, 1.3)
						else:
								sprite.modulate = Color.WHITE

func _on_settings_clicked(_viewport, event, _shape_idx):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				print("Settings clicked!")
				emit_signal("open_settings")

func _on_game_btn_clicked(_viewport, event, _shape_idx):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				print("Game button clicked!")
				if tournament_code.length() != 4:
						tournament_code = _generate_code()
						code_input.text = tournament_code
						print("Generated code: ", tournament_code)
				emit_signal("play_pressed")

func _on_floating_btn_clicked(event, btn_name: String):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				print("Floating button clicked: ", btn_name)
				if btn_name == "mask":
						emit_signal("open_masks")
				elif btn_name == "powerup":
						emit_signal("open_powerups")

func _generate_code() -> String:
		var code = ""
		for i in range(4):
				code += CODE_CHARACTERS[randi() % CODE_CHARACTERS.length()]
		return code

func _filter_valid_chars(text: String) -> String:
		var filtered = ""
		for c in text.to_upper():
				if c in CODE_CHARACTERS:
						filtered += c
		return filtered

func _on_code_text_changed(new_text: String):
		var filtered = _filter_valid_chars(new_text)
		if filtered != new_text.to_upper():
				code_input.text = filtered
				code_input.caret_column = filtered.length()
		tournament_code = filtered

func _input(event):
		if event.is_action_pressed("ui_cancel"):
				get_tree().quit()
		
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				var mouse_pos = event.position
				
				if settings_btn_sprite and _is_point_in_sprite(mouse_pos, settings_btn_sprite):
						print("Settings clicked via _input!")
						emit_signal("open_settings")
						return
				
				if _is_point_in_new_game_zone(mouse_pos):
						print("NEW GAME clicked!")
						tournament_code = _generate_code()
						code_input.text = tournament_code
						print("Generated code: ", tournament_code)
						return
				
				if _is_point_in_join_zone(mouse_pos):
						print("JOIN clicked!")
						if tournament_code.length() == 4:
								print("Joining with code: ", tournament_code)
								emit_signal("play_pressed")
						else:
								print("Need valid 4-character code to join")
						return
				
				if mask_btn and _is_point_in_rigidbody(mouse_pos, mask_btn):
						print("Mask button clicked via _input!")
						emit_signal("open_masks")
						return
				
				if powerup_btn and _is_point_in_rigidbody(mouse_pos, powerup_btn):
						print("Powerup button clicked via _input!")
						emit_signal("open_powerups")
						return

func _is_point_in_sprite(point: Vector2, sprite: Sprite2D) -> bool:
		if not sprite.texture:
				return false
		var tex_size = sprite.texture.get_size()
		var rect = Rect2(sprite.position - tex_size / 2, tex_size)
		return rect.has_point(point)

func _is_point_in_rigidbody(point: Vector2, body: RigidBody2D) -> bool:
		var sprite = body.get_node_or_null("Sprite")
		if not sprite or not sprite.texture:
				return false
		var tex_size = sprite.texture.get_size()
		var rect = Rect2(body.position - tex_size / 2, tex_size)
		return rect.has_point(point)

func _is_point_in_code_input(point: Vector2) -> bool:
		if not code_input:
				return false
		var rect = Rect2(code_input.position, code_input.size)
		return rect.has_point(point)

func _is_point_in_new_game_zone(point: Vector2) -> bool:
		var btn_top_left = game_btn_sprite.position - game_btn_size / 2
		var zone = Rect2(btn_top_left.x + 100 - 100, btn_top_left.y + 170 - 30, 200, 60)
		return zone.has_point(point)

func _is_point_in_join_zone(point: Vector2) -> bool:
		var btn_top_left = game_btn_sprite.position - game_btn_size / 2
		var zone = Rect2(btn_top_left.x + 340 - 100, btn_top_left.y + 170 - 30, 200, 60)
		return zone.has_point(point)
