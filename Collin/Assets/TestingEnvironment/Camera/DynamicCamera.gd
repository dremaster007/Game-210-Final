extends Camera2D

# for this to work, it needs to be a child singular child of the main scene, and the main
# scene needs to have a container called "Player_Container" with all of the players in it

export (float) var zoom_offset = 0.4 # this is the leeway that the zoom will take place
export (bool) var debug_mode = true # will draw a visual helper to see whats happening

var camera_rect = Rect2() # the cameras rectangle
var viewport_rect = Rect2() # the viewports rectangle

var number_of_players = 0 # number of players in game

# character variables, we can have up to 4 players
var player1 = null
var player2 = null
var player3 = null
var player4 = null

var player_array = [] # array that will be populated with objects of players

var Global = null

func _ready():
	set_process(false) # stop process
	Global = find_parent("Global")

func cam_start():
	yield(get_tree().create_timer(0.05), "timeout") # wait for main scene to catch up
	number_of_players = Global.number_of_players # set the number of players we have
	for player in number_of_players: # loop over the number of players we have
		match player + 1: # set the player variables to the corresponding variables
			0:
				return
			1:
				player1 = find_parent("DragonLevel").find_node("Player_Container").get_child(player)
				#player1 = get_parent().get_node("Player_Container/Player")
				player_array.append(player1)
			2:
				player2 = find_parent("DragonLevel").find_node("Player_Container").get_child(player)
				#player2 = get_parent().get_node("Player_Container/Player2")
				player_array.append(player2)
			3:
				player3 = find_parent("DragonLevel").find_node("Player_Container").get_child(player)
				player_array.append(player3)
			4:
				player4 = find_parent("DragonLevel").find_node("Player_Container").get_child(player)
				player_array.append(player4)
	viewport_rect = get_viewport_rect() # set the viewport rect 
	set_process(true) # set process true

func _process(delta):
	var planned_offset
	var planned_zoom
	camera_rect = Rect2(player_array[0].global_position, Vector2()) # set the camera rect to first player
	var counter = 0 # loop helper
	for index in player_array: # loop over the player array objects
		if counter == 0: # if the counter is 0 
			counter += 1 # increase it
			continue # skip to next index
		camera_rect = camera_rect.expand(player_array[counter].global_position) # add another character to the extents
		counter += 1 # increase counter
	
	planned_offset = calculate_center(camera_rect) # set our offset
	planned_zoom = calculate_zoom(camera_rect, viewport_rect.size) # set our size
	
	$CameraTween.interpolate_property(self, "offset", offset, planned_offset, 0.4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$CameraTween.interpolate_property(self, "zoom", zoom, planned_zoom, 0.4, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$CameraTween.start()
	
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