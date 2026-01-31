extends Node3D

signal play_pressed
signal join_game(code: String)

var tournament_code: String = ""
const CODE_CHARACTERS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"

var cyclorama: Node3D
var title_generator: Node3D
var ui_layer: CanvasLayer
var code_input: LineEdit
var join_button: Button

const COLOR_GOLD = Color(1.0, 0.85, 0.3)
const COLOR_DARK_BG = Color(0.08, 0.05, 0.12)
const COLOR_PANEL_BG = Color(0.12, 0.08, 0.18, 0.95)
const COLOR_ACCENT_BLUE = Color(0.2, 0.5, 0.9)
const COLOR_ACCENT_ORANGE = Color(0.9, 0.5, 0.2)
const COLOR_BUTTON_GREEN = Color(0.15, 0.6, 0.3)
const COLOR_BUTTON_RED = Color(0.7, 0.15, 0.15)

func _ready():
	_setup_3d_scene()
	_setup_ui()

func _setup_3d_scene():
	var cyclorama_scene = load("res://scenes/main-menu/components/cyclorama.tscn")
	if cyclorama_scene:
		cyclorama = cyclorama_scene.instantiate()
		add_child(cyclorama)
	
	var title_scene = load("res://scenes/main-menu/components/title_generator.tscn")
	if title_scene:
		title_generator = title_scene.instantiate()
		title_generator.position = Vector3(0, 2.5, 0)
		add_child(title_generator)

func _setup_ui():
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)
	
	var main_container = Control.new()
	main_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(main_container)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_container.add_child(center)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 25)
	center.add_child(vbox)
	
	var spacer_top = Control.new()
	spacer_top.custom_minimum_size = Vector2(0, 180)
	vbox.add_child(spacer_top)
	
	var tournament_panel = _create_tournament_panel()
	vbox.add_child(tournament_panel)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(spacer)
	
	var play_btn = _create_styled_button("START GAME", COLOR_BUTTON_GREEN, Vector2(260, 60))
	play_btn.pressed.connect(_on_play_button_pressed)
	vbox.add_child(play_btn)
	
	var quit_btn = _create_styled_button("QUIT", COLOR_BUTTON_RED, Vector2(260, 50))
	quit_btn.pressed.connect(_on_quit_button_pressed)
	vbox.add_child(quit_btn)

func _create_tournament_panel() -> PanelContainer:
	var panel = PanelContainer.new()
	
	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_PANEL_BG
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = COLOR_GOLD.darkened(0.3)
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.content_margin_left = 30
	style.content_margin_right = 30
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.shadow_size = 8
	style.shadow_offset = Vector2(0, 4)
	panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	panel.add_child(vbox)
	
	var label = Label.new()
	label.text = "TOURNAMENT CODE"
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", COLOR_GOLD)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label)
	
	code_input = LineEdit.new()
	code_input.placeholder_text = "XXXX"
	code_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	code_input.max_length = 4
	code_input.custom_minimum_size = Vector2(180, 55)
	code_input.add_theme_font_size_override("font_size", 36)
	code_input.add_theme_color_override("font_color", Color.WHITE)
	code_input.add_theme_color_override("font_placeholder_color", Color(0.4, 0.35, 0.5))
	
	var input_style = StyleBoxFlat.new()
	input_style.bg_color = Color(0.05, 0.03, 0.08)
	input_style.border_width_bottom = 3
	input_style.border_color = COLOR_GOLD.darkened(0.2)
	input_style.corner_radius_top_left = 8
	input_style.corner_radius_top_right = 8
	input_style.corner_radius_bottom_left = 8
	input_style.corner_radius_bottom_right = 8
	code_input.add_theme_stylebox_override("normal", input_style)
	code_input.add_theme_stylebox_override("focus", input_style)
	
	code_input.text_changed.connect(_on_code_text_changed)
	vbox.add_child(code_input)
	
	var btn_container = HBoxContainer.new()
	btn_container.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_container.add_theme_constant_override("separation", 20)
	vbox.add_child(btn_container)
	
	var gen_btn = _create_styled_button("GENERATE", COLOR_ACCENT_BLUE, Vector2(130, 45))
	gen_btn.pressed.connect(_on_generate_code_pressed)
	btn_container.add_child(gen_btn)
	
	join_button = _create_styled_button("JOIN", COLOR_ACCENT_ORANGE, Vector2(130, 45))
	join_button.disabled = true
	join_button.pressed.connect(_on_join_game_pressed)
	btn_container.add_child(join_button)
	
	return panel

func _create_styled_button(text: String, color: Color, min_size: Vector2) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = min_size
	btn.add_theme_font_size_override("font_size", 22)
	btn.add_theme_color_override("font_color", Color.WHITE)
	
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = 4
	style.shadow_offset = Vector2(0, 3)
	btn.add_theme_stylebox_override("normal", style)
	
	var hover_style = style.duplicate()
	hover_style.bg_color = color.lightened(0.15)
	hover_style.shadow_size = 6
	btn.add_theme_stylebox_override("hover", hover_style)
	
	var pressed_style = style.duplicate()
	pressed_style.bg_color = color.darkened(0.15)
	pressed_style.shadow_size = 2
	pressed_style.shadow_offset = Vector2(0, 1)
	btn.add_theme_stylebox_override("pressed", pressed_style)
	
	var disabled_style = style.duplicate()
	disabled_style.bg_color = Color(0.3, 0.3, 0.35)
	btn.add_theme_stylebox_override("disabled", disabled_style)
	btn.add_theme_color_override("font_disabled_color", Color(0.5, 0.5, 0.55))
	
	return btn

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

func _on_generate_code_pressed() -> void:
	tournament_code = _generate_code()
	code_input.text = tournament_code
	join_button.disabled = false

func _on_code_text_changed(new_text: String) -> void:
	var filtered = _filter_valid_chars(new_text)
	if filtered != new_text.to_upper():
		code_input.text = filtered
		code_input.caret_column = filtered.length()
	tournament_code = filtered
	join_button.disabled = tournament_code.length() != 4

func _on_join_game_pressed() -> void:
	if tournament_code.length() == 4:
		emit_signal("join_game", tournament_code)
		emit_signal("play_pressed")

func _on_play_button_pressed() -> void:
	if tournament_code.length() != 4:
		tournament_code = _generate_code()
		code_input.text = tournament_code
	emit_signal("play_pressed")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
