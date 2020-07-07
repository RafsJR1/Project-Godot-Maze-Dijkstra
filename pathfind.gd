extends TileMap

export(Vector2) var map_size = Vector2(16, 16)

var path_start_position = Vector2() setget _set_path_start_position
var path_end_position = Vector2() setget _set_path_end_position

var _point_path = []

const BASE_LINE_WIDTH = 2.0
const DRAW_COLOR = Color('#fff')

enum STATES { IDLE, FIND_PATH }
var _state = null

var path = []
var target_point_world = Vector2()
var target_position = Vector2()
var start_position =  Vector2()

onready var dijkstra_node = AStar.new()
onready var obstacles = get_used_cells_by_id(0)
onready var _half_cell_size = cell_size / 2


func _ready():
	_change_state(STATES.IDLE)
	var walkable_cells_list = dijkstra_add_walkable_cells(obstacles)
	dijkstra_connect_walkable_cells(walkable_cells_list)

func _change_state(new_state):
	if new_state == STATES.FIND_PATH:
		path = get_parent().get_node('TileMap').find_path(start_position, target_position)
		if not path or len(path) == 1:
			_change_state(STATES.IDLE)
			return

		target_point_world = path[1]
	_state = new_state

func _input(event):
	if event.is_action_pressed('click'):
		if Input.is_key_pressed(KEY_SHIFT):
			start_position = get_global_mouse_position()
		else:
			target_position = get_global_mouse_position()

		_change_state(STATES.FIND_PATH)

# Adiciona todos os pontos a matrix esxceto pelo
# pelos obstáculos
func dijkstra_add_walkable_cells(obstacles = []):
	var points_array = []

	for y in range(map_size.y):
		for x in range(map_size.x):
			var point = Vector2(x, y)
			if point in obstacles:
				continue

			points_array.append(point)
			dijkstra_node.add_point(calculate_point_index(point), Vector3(point.x, point.y, 0.0))
	return points_array


func dijkstra_connect_walkable_cells(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		# Para todas as celulas, ele verifica os vizinhos,
		# se não for um obstáculo ele conecta ambos
		var points_relative = PoolVector2Array([
			Vector2(point.x + 1, point.y),
			Vector2(point.x - 1, point.y),
			Vector2(point.x, point.y + 1),
			Vector2(point.x, point.y - 1)])

		for point_relative in points_relative:
			var point_relative_index = calculate_point_index(point_relative)

			if is_outside_map_bounds(point_relative) or not dijkstra_node.has_point(point_relative_index):
				continue

			dijkstra_node.connect_points(point_index, point_relative_index)


func is_outside_map_bounds(point):
	return point.x < 0 or point.y < 0 or point.x >= map_size.x or point.y >= map_size.y


func calculate_point_index(point):
	return point.x + map_size.x * point.y


func find_path(world_start, world_end):
	self.path_start_position = world_to_map(world_start)
	self.path_end_position = world_to_map(world_end)
	_recalculate_path()
	var path_world = []
	for point in _point_path:
		var point_world = map_to_world(Vector2(point.x, point.y)) + _half_cell_size
		path_world.append(point_world)
	return path_world


func _recalculate_path():
	clear_previous_path_drawing()
	var start_point_index = calculate_point_index(path_start_position)
	var end_point_index = calculate_point_index(path_end_position)
	_point_path = dijkstra_node.get_point_path(start_point_index, end_point_index)

	update()


func clear_previous_path_drawing():
	if not _point_path:
		return
	var point_start = _point_path[0]
	var point_end = _point_path[len(_point_path) - 1]

	set_cell(point_start.x, point_start.y, -1)
	set_cell(point_end.x, point_end.y, -1)

# Gera os desenhos
func _draw():
	if not _point_path:
		return
	var point_start = _point_path[0]
	var point_end = _point_path[len(_point_path) - 1]

	set_cell(point_start.x, point_start.y, 1)
	set_cell(point_end.x, point_end.y, 2)

	var last_point = map_to_world(Vector2(point_start.x, point_start.y)) + _half_cell_size

	for index in range(1, len(_point_path)):
		var current_point = map_to_world(Vector2(_point_path[index].x, _point_path[index].y)) + _half_cell_size
		draw_line(last_point, current_point, DRAW_COLOR, BASE_LINE_WIDTH, true)
		draw_circle(current_point, BASE_LINE_WIDTH * 2.0, DRAW_COLOR)
		last_point = current_point

func _set_path_start_position(value):
	if value in obstacles or is_outside_map_bounds(value):
		return

	set_cell(path_start_position.x, path_start_position.y, -1)
	set_cell(value.x, value.y, 1)
	path_start_position = value

	if path_end_position and path_end_position != path_start_position:
		_recalculate_path()


func _set_path_end_position(value):
	if value in obstacles or is_outside_map_bounds(value):
		return

	set_cell(path_start_position.x, path_start_position.y, -1)
	set_cell(value.x, value.y, 2)
	path_end_position = value

	if path_start_position != value:
		_recalculate_path()
