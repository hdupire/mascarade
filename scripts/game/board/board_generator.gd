extends Node3D

@export var grid_size := 25
@export var cell_size := 1.2
@export var mask_radius := 12.0

var cells := {}

func _ready() -> void:
	generate_board()
	render_floor()

func generate_board():
	cells.clear()

	for x in range(grid_size):
		for y in range(grid_size):
			var nx = (x / float(grid_size - 1)) * 2.0 - 1.0
			var ny = (y / float(grid_size - 1)) * 2.0 - 1.0

			var dist = sqrt(nx * nx + ny * ny)

			if dist > 1.0:
				continue

			var cell = BoardCell.new()
			cell.grid_pos = Vector2i(x, y)
			cell.world_pos = Vector3(
				(x - grid_size / 2) * cell_size,
				0,
				(y - grid_size / 2) * cell_size
			)

			cells[cell.grid_pos] = cell

	connect_neighbors()

func connect_neighbors():
	var dirs = [
		Vector2i(1,0),
		Vector2i(-1,0),
		Vector2i(0,1),
		Vector2i(0,-1)
	]

	for cell in cells.values():
		for d in dirs:
			var npos = cell.grid_pos + d
			if cells.has(npos):
				cell.neighbors.append(cells[npos])

func render_floor():
	var plane := PlaneMesh.new()
	plane.size = Vector2(
		grid_size * cell_size,
		grid_size * cell_size
	)

	$Floor.mesh = plane

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.55, 0.38, 0.25)
	mat.roughness = 0.85
	$Floor.material_override = mat
