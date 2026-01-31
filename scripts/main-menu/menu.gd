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
		title_generator.position = Vector3(0, 2, 0)
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
	spacer_top.custom_minimum_size = Vector2(0, 150)
	vbox.add_child(spacer_top)
	
	var tournament_panel = _create_tournament_panel()
	vbox.add_child(tournament_panel)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 30)
	vbox.add_child(spacer)
	
	var play_btn = _create_button("Start Game", Color(0.2, 0.7, 0.3))
	play_btn.pressed.connect(_on_play_button_pressed)
	vbox.add_child(play_btn)
	
	var quit_btn = _create_button("Quit", Color(0.7, 0.2, 0.2))
	quit_btn.pressed.connect(_on_quit_button_pressed)
	vbox.add_child(quit_btn)

func _create_tournament_panel() -> PanelContainer:
	var panel = PanelContainer.new()
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.12, 0.2, 0.9)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 15
	style.content_margin_bottom = 15
	panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)
	
	var label = Label.new()
	label.text = "Tournament Code"
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(1, 0.85, 0.4))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label)
	
	code_input = LineEdit.new()
	code_input.placeholder_text = "XXXX"
	code_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	code_input.max_length = 4
	code_input.custom_minimum_size = Vector2(150, 40)
	code_input.add_theme_font_size_override("font_size", 28)
	code_input.text_changed.connect(_on_code_text_changed)
	vbox.add_child(code_input)
	
	var btn_container = HBoxContainer.new()
	btn_container.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_container.add_theme_constant_override("separation", 15)
	vbox.add_child(btn_container)
	
	var gen_btn = _create_button("Generate", Color(0.3, 0.5, 0.8), Vector2(120, 40))
	gen_btn.pressed.connect(_on_generate_code_pressed)
	btn_container.add_child(gen_btn)
	
	join_button = _create_button("Join", Color(0.8, 0.5, 0.3), Vector2(120, 40))
	join_button.disabled = true
	join_button.pressed.connect(_on_join_game_pressed)
	btn_container.add_child(join_button)
	
	return panel

func _create_button(text: String, color: Color, min_size: Vector2 = Vector2(200, 50)) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.custom_minimum_size = min_size
	btn.add_theme_font_size_override("font_size", 20)
	
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	btn.add_theme_stylebox_override("normal", style)
	
	var hover_style = style.duplicate()
	hover_style.bg_color = color.lightened(0.2)
	btn.add_theme_stylebox_override("hover", hover_style)
	
	var pressed_style = style.duplicate()
	pressed_style.bg_color = color.darkened(0.2)
	btn.add_theme_stylebox_override("pressed", pressed_style)
	
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
