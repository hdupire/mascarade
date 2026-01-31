extends Node3D

@export var button_text: String = "PLAY"
@export var hover_height: float = 0.2
@export var hover_speed: float = 2.0
@export var button_color: Color = Color(0.2, 0.6, 0.8)

var time_passed: float = 0.0
var base_y_position: float = 0.0

signal button_clicked

@onready var button_mesh: MeshInstance3D

func _ready():
	base_y_position = position.y
	create_button_visual()

func create_button_visual():
	# Créer ou réutilise le cube pour le bouton
	if has_node("ButtonMesh"):
		button_mesh = $ButtonMesh
	else:
		button_mesh = MeshInstance3D.new()
		button_mesh.name = "ButtonMesh"
		button_mesh.mesh = BoxMesh.new()
		button_mesh.mesh.size = Vector3(1.0, 0.2, 1.0)
		add_child(button_mesh)
	
	# Matériau
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.6, 0.8)  # Bleu
	button_mesh.material_override = material

func _input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("button_clicked")

func _process(delta):
	# Animation de flottement
	time_passed += delta
	var new_y = base_y_position + sin(time_passed * hover_speed) * hover_height
	position.y = new_y
