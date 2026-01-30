class_name Board

# Grid of playable spaces

const WIDTH := 40
const HEIGHT := 40

var grid := []

class Cell:
	var is_walkable := false
	var walls := {"N": false, "S": false, "W": false, "E": false}

func _init():
	for y in HEIGHT:
		grid.append([])
		for x in WIDTH:
			grid[y].append(Cell.new())
			
func is_walkable(pos: Vector2i):
	return grid[pos.y][pos.x].is_walkable
