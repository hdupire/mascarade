extends Node3D

var gradient_colors: Array[Color] = []

func _ready():
        _pick_random_colors()
        _create_3d_title()

func _pick_random_colors():
        var base_hue = randf()
        gradient_colors = [
                Color.from_hsv(base_hue, 0.7, 0.9),
                Color.from_hsv(fmod(base_hue + 0.15, 1.0), 0.8, 0.85),
                Color.from_hsv(fmod(base_hue + 0.35, 1.0), 0.75, 0.8),
        ]

func _create_3d_title():
        var title_text = "MASQUERADE"
        var letter_spacing = 0.7
        var start_x = -letter_spacing * (title_text.length() - 1) / 2.0
        
        for i in range(title_text.length()):
                var letter = title_text[i]
                var letter_node = _create_3d_letter(letter, i, title_text.length())
                letter_node.position = Vector3(start_x + i * letter_spacing, 0, 0)
                letter_node.rotation_degrees.y = randf_range(-5, 5)
                letter_node.rotation_degrees.z = randf_range(-3, 3)
                $TitleNode.add_child(letter_node)

func _create_3d_letter(letter: String, index: int, total: int) -> Node3D:
        var letter_root = Node3D.new()
        
        var text_mesh = TextMesh.new()
        text_mesh.text = letter
        text_mesh.depth = 0.15
        text_mesh.pixel_size = 0.01
        text_mesh.font_size = 96
        text_mesh.curve_step = 2.0
        
        var mesh_instance = MeshInstance3D.new()
        mesh_instance.mesh = text_mesh
        
        var t = float(index) / float(total - 1) if total > 1 else 0.5
        var letter_color = gradient_colors[0].lerp(gradient_colors[1], t)
        letter_color = letter_color.lerp(gradient_colors[2], t * t)
        
        var material = StandardMaterial3D.new()
        material.albedo_color = letter_color
        material.roughness = 0.65
        material.metallic = 0.05
        
        mesh_instance.material_override = material
        
        letter_root.add_child(mesh_instance)
        
        _add_tribal_decoration(letter_root, letter, letter_color)
        
        return letter_root

func _add_tribal_decoration(parent: Node3D, letter: String, color: Color):
        var deco_chance = 0.6
        if randf() > deco_chance:
                return
        
        var deco_type = randi() % 4
        var deco = MeshInstance3D.new()
        var deco_mat = StandardMaterial3D.new()
        deco_mat.albedo_color = color.darkened(0.3)
        deco_mat.roughness = 0.7
        
        match deco_type:
                0:
                        var sphere = SphereMesh.new()
                        sphere.radius = 0.08
                        sphere.height = 0.16
                        deco.mesh = sphere
                        deco.position = Vector3(randf_range(-0.15, 0.15), 0.5, 0.1)
                1:
                        var cylinder = CylinderMesh.new()
                        cylinder.top_radius = 0.03
                        cylinder.bottom_radius = 0.03
                        cylinder.height = 0.3
                        deco.mesh = cylinder
                        deco.position = Vector3(0, 0.55, 0.08)
                        deco.rotation_degrees.x = 90
                2:
                        var box = BoxMesh.new()
                        box.size = Vector3(0.06, 0.25, 0.04)
                        deco.mesh = box
                        deco.position = Vector3(randf_range(-0.1, 0.1), 0.5, 0.08)
                        deco.rotation_degrees.z = randf_range(-20, 20)
                3:
                        var torus = TorusMesh.new()
                        torus.inner_radius = 0.04
                        torus.outer_radius = 0.08
                        deco.mesh = torus
                        deco.position = Vector3(0, 0.55, 0.1)
        
        deco.material_override = deco_mat
        parent.add_child(deco)
