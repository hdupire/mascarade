extends Node3D

func _ready():
	var texture = load("res://assets/masquerade_title.svg")
	if texture:
		var sprite = Sprite3D.new()
		sprite.texture = texture
		sprite.pixel_size = 0.03
		sprite.billboard = false
		$TitleNode.add_child(sprite)
	else:
		_create_bold_title()

func _create_bold_title():
	var title_text = "MASQUERADE"
	var colors = _get_random_gradient_colors()
	
	var letter_spacing = 0.55
	var start_x = -letter_spacing * (title_text.length() - 1) / 2.0
	
	for i in range(title_text.length()):
		var letter = title_text[i]
		var label = Label3D.new()
		label.text = letter
		label.font_size = 200
		label.pixel_size = 0.008
		label.outline_size = 24
		label.outline_modulate = Color(0.1, 0.05, 0.02)
		
		var t = float(i) / float(title_text.length() - 1)
		label.modulate = colors[0].lerp(colors[1], t).lerp(colors[2], t * t)
		
		label.position = Vector3(start_x + i * letter_spacing, 0, 0)
		label.rotation_degrees.y = randf_range(-8, 8)
		label.rotation_degrees.z = randf_range(-5, 5)
		
		$TitleNode.add_child(label)

func _get_random_gradient_colors() -> Array[Color]:
	var palettes = [
		[Color(1.0, 0.3, 0.1), Color(1.0, 0.7, 0.0), Color(0.9, 0.2, 0.4)],
		[Color(0.2, 0.8, 0.9), Color(0.6, 0.3, 0.9), Color(0.9, 0.2, 0.5)],
		[Color(1.0, 0.85, 0.2), Color(0.9, 0.4, 0.1), Color(0.7, 0.1, 0.3)],
		[Color(0.3, 0.9, 0.4), Color(0.1, 0.7, 0.8), Color(0.5, 0.2, 0.8)],
	]
	var palette = palettes[randi() % palettes.size()]
	var result: Array[Color] = []
	for c in palette:
		result.append(c)
	return result
