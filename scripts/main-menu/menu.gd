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

const WOOD_DARK = Color(0.35, 0.22, 0.12)
const WOOD_MEDIUM = Color(0.5, 0.32, 0.18)
const WOOD_LIGHT = Color(0.65, 0.45, 0.25)
const CREAM = Color(0.95, 0.9, 0.8)
const TRIBAL_ACCENT = Color(0.8, 0.35, 0.15)

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
		title_generator.position = Vector3(0, 2.2, 0)
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
	vbox.add_theme_constant_override("separation", 20)
	center.add_child(vbox)
	
	var spacer_top = Control.new()
	spacer_top.custom_minimum_size = Vector2(0, 160)
	vbox.add_child(spacer_top)
	
	var tournament_panel = _create_tournament_panel()
	vbox.add_child(tournament_panel)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 15)
	vbox.add_child(spacer)
	
	var play_btn = _create_wooden_button("START GAME", TRIBAL_ACCENT)
	play_btn.pressed.connect(_on_play_button_pressed)
	vbox.add_child(play_btn)
	
	var quit_btn = _create_wooden_button("QUIT", WOOD_DARK)
	quit_btn.pressed.connect(_on_quit_button_pressed)
	vbox.add_child(quit_btn)

func _create_tournament_panel() -> PanelContainer:
	var panel = PanelContainer.new()
	
	var style = StyleBoxFlat.new()
	style.bg_color = WOOD_MEDIUM
	style.border_width_left = 4
	style.border_width_right = 4
	style.border_width_top = 4
	style.border_width_bottom = 4
	style.border_color = WOOD_DARK
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	style.content_margin_left = 25
	style.content_margin_right = 25
	style.content_margin_top = 18
	style.content_margin_bottom = 18
	panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)
	
	var label = Label.new()
	label.text = "TOURNAMENT CODE"
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", CREAM)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label)
	
	code_input = LineEdit.new()
	code_input.placeholder_text = "XXXX"
	code_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	code_input.max_length = 4
	code_input.custom_minimum_size = Vector2(160, 50)
	code_input.add_theme_font_size_override("font_size", 32)
	code_input.add_theme_color_override("font_color", WOOD_DARK)
	code_input.add_theme_color_override("font_placeholder_color", WOOD_LIGHT)
	
	var input_style = StyleBoxFlat.new()
	input_style.bg_color = CREAM
	input_style.border_width_left = 3
	input_style.border_width_right = 3
	input_style.border_width_top = 3
	input_style.border_width_bottom = 3
	input_style.border_color = WOOD_DARK
	input_style.corner_radius_top_left = 12
	input_style.corner_radius_top_right = 12
	input_style.corner_radius_bottom_left = 12
	input_style.corner_radius_bottom_right = 12
	code_input.add_theme_stylebox_override("normal", input_style)
	code_input.add_theme_stylebox_override("focus", input_style)
	
	code_input.text_changed.connect(_on_code_text_changed)
	vbox.add_child(code_input)
	
	var btn_container = HBoxContainer.new()
	btn_container.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_container.add_theme_constant_override("separation", 15)
	vbox.add_child(btn_container)
	
	var gen_btn = _create_wooden_button("GENERATE", WOOD_LIGHT, Vector2(120, 40), 18)
	gen_btn.pressed.connect(_on_generate_code_pressed)
	btn_container.add_child(gen_btn)
	
	join_button = _create_wooden_button("JOIN", TRIBAL_ACCENT, Vector2(120, 40), 18)
	join_button.disabled = true
	join_button.pressed.connect(_on_join_game_pressed)
	btn_container.add_child(join_button)
	
	return panel

func _create_wooden_button(text: String, color: Color, min_size: Vector2 = Vector2(220, 55), font_size: int = 22) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = min_size
	btn.add_theme_font_size_override("font_size", font_size)
	btn.add_theme_color_override("font_color", CREAM)
	
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = WOOD_DARK
	style.corner_radius_top_left = 15
	style.corner_radius_top_right = 15
	style.corner_radius_bottom_left = 15
	style.corner_radius_bottom_right = 15
	btn.add_theme_stylebox_override("normal", style)
	
	var hover_style = style.duplicate()
	hover_style.bg_color = color.lightened(0.15)
	btn.add_theme_stylebox_override("hover", hover_style)
	
	var pressed_style = style.duplicate()
	pressed_style.bg_color = color.darkened(0.15)
	btn.add_theme_stylebox_override("pressed", pressed_style)
	
	var disabled_style = style.duplicate()
	disabled_style.bg_color = Color(0.4, 0.35, 0.3)
	disabled_style.border_color = Color(0.3, 0.25, 0.2)
	btn.add_theme_stylebox_override("disabled", disabled_style)
	btn.add_theme_color_override("font_disabled_color", Color(0.6, 0.55, 0.5))
	
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
