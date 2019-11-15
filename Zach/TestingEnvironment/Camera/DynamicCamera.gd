extends Camera2D

export (float) var zoom_offset = 0.4
export (bool) var debug_mode = false

var camera_rect = Rect2()
var viewport_rect = Rect2()

var number_of_players = 0

var player1 = null
var player2 = null
var player3 = null
var player4 = null

var player_array = []

func _ready():
	set_process(false)
	yield(get_tree().create_timer(0.05), "timeout")
	number_of_players = get_parent().number_of_players
	for player in number_of_players:
		match player + 1:
			0:
				return
			1:
				player1 = get_parent().get_node("Player_Container/Player")
				player_array.append(player1)
			2:
				player2 = get_parent().get_node("Player_Container/Player2")
				player_array.append(player2)
			3:
				player3 = get_parent().get_node("Player_Container/Player3")
				player_array.append(player3)
			4:
				player4 = get_parent().get_node("Player_Container/Player4")
				player_array.append(player4)
	viewport_rect = get_viewport_rect()
	print(player_array)
	set_process(true)

func _process(delta):
	camera_rect = Rect2(player_array[0].global_position, Vector2())
	var counter = 0
	for index in player_array:
		if counter == 0:
			counter += 1
			continue
		camera_rect = camera_rect.expand(player_array[counter].global_position)
		counter += 1
	counter = 0
	
	offset = calculate_center(camera_rect)
	zoom = calculate_zoom(camera_rect, viewport_rect.size)
	
	if debug_mode:
		update()

func calculate_center(rect):
	return Vector2(
		rect.position.x + rect.size.x / 2,
		rect.position.y + rect.size.y / 2)

func calculate_zoom(rect, viewport_size):
	var min_zoom = 0.5
	var max_zoom = max(
		max(min_zoom, rect.size.x / viewport_size.x + zoom_offset),
		max(min_zoom, rect.size.y / viewport_size.y + zoom_offset))
	return Vector2(max_zoom, max_zoom)

func _draw():
	if not debug_mode:
		return
	draw_rect(camera_rect, Color("#ffffff"), false)
	draw_circle(calculate_center(camera_rect), 5, Color("#ffffff"))