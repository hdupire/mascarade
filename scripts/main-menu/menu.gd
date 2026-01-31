extends Node3D

var cube
var sphere

func _ready():
	print("=== CAMERA TEST SIMPLE ===")
	
	# 1. Caméra
	var camera = Camera3D.new()
	camera.position = Vector3(0, 1, 5)
	camera.rotation_degrees = Vector3(0, 180, 0)
	camera.current = true
	add_child(camera)
	
	# 2. Cube ROUGE
	cube = MeshInstance3D.new()
	cube.mesh = BoxMesh.new()
	cube.mesh.size = Vector3(3, 3, 3)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.RED
	cube.material_override = mat
	add_child(cube)
	cube.name = "TestCube"
	
	# 3. Sphère VERTE
	sphere = MeshInstance3D.new()
	sphere.mesh = SphereMesh.new()
	sphere.mesh.radius = 1
	var mat2 = StandardMaterial3D.new()
	mat2.albedo_color = Color.GREEN
	sphere.material_override = mat2
	sphere.position = Vector3(0, 0, -2)
	add_child(sphere)
	sphere.name = "TestSphere"
	
	print("Test prêt - Écran devrait être ROUGE/VERT")

func _process(delta):
	# Quitter avec Échap
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	# Tourner les objets
	cube.rotation.y += delta
	sphere.rotation.y += delta * 2
