extends Node2D

@onready var timer: Timer = $Timer

@export var cell_scene: PackedScene

var rows: int = 15 # 480 / 32
var cols: int = 20 # 640 / 32
var cell_width = 32

var cell_matrix: Array = []
var prev_cell_states: Array = []


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("confirm"):
		set_game()


func clear_board() -> void:
	cell_matrix.resize(0)
	prev_cell_states.resize(0)


func set_game() -> void:
	clear_board()
	
	for col in range(cols):
		cell_matrix.append([])
		cell_matrix[col].resize(rows)
		prev_cell_states.append([])
		prev_cell_states[col].resize(rows)
		for row in range(rows):
			var cell = cell_scene.instantiate()
			self.add_child(cell)
			
			cell.position = Vector2(col * cell_width + 16, row * cell_width + 16)
			
			if !randi() % 2 or is_edge(col, row):
				cell.visible = false
				prev_cell_states[col].push_back(false)
			else:
				prev_cell_states[col].push_back(true)
			
			cell_matrix[col][row] = cell
	
	game()


func game() -> void:
	for col in range(cols):
		for row in range(rows):
			if cell_matrix[col][row].visible:
				prev_cell_states[col][row] = true
			else:
				prev_cell_states[col][row] = false
	
	for col in range(cols):
		for row in range(rows):
			if !is_edge(col, row):
				cell_matrix[col][row].visible = get_next_state(col, row)
	
	timer.start()
	await timer.timeout
	
	game()


func is_edge(col: int, row: int) -> bool:
	return row == 0 or row == rows -1 or col == 0 or col == cols - 1


func get_neighbours(col: int, row: int) -> int:
	var neighbours: int = 0
	
	for x in range(-1, 2):
		for y in range(-1, 2):
			if x != 0 or y != 0:
				if prev_cell_states[col + x][row + y]:
					neighbours += 1
	
	return neighbours


func get_next_state(col: int, row: int) -> bool:
	var cur = prev_cell_states[col][row]
	var neighbours = get_neighbours(col, row)
	
	if cur:
		if neighbours > 3:
			return false
		elif neighbours < 2:
			return false
	else:
		if neighbours == 3:
			return true
	
	return cur
