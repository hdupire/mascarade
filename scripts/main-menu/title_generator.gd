extends Node3D

func _ready():
	var texture = load("res://assets/masquerade_title.svg")
	print("SVG loaded: ", texture != null)
	if texture:
		var sprite = Sprite3D.new()
		sprite.texture = texture
		sprite.pixel_size = 0.03
		sprite.billboard = false
		add_child(sprite)
