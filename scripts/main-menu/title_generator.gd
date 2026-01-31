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
		var label = Label3D.new()
		label.text = "MASQUERADE"
		label.font_size = 128
		label.modulate = Color(1, 0.85, 0.4)
		label.outline_modulate = Color(0.4, 0.2, 0.1)
		label.outline_size = 8
		$TitleNode.add_child(label)
