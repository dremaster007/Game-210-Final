extends Node

export (PackedScene) var Title_Screen
export (PackedScene) var Picking_Screen
export (PackedScene) var Play_Screen
export (PackedScene) var HUD

var number_of_players = 1

var player_picks = {"player_1": 0, "player_2": 0, "player_3": 0, "player_4": 0}

func _ready():
	OS.window_fullscreen = true
	Input.connect("joy_connection_changed", self, "_joy_connection_changed")
	get_joypads()
	change_scene(Title_Screen)

func _joy_connection_changed(device_id, is_connected):
	get_joypads()
	#print("Device ", device_id, " connected_status = ", is_connected)

func get_joypads():
	number_of_players = 1
	var joypads = Input.get_connected_joypads()
	if joypads != []:
		for item in joypads:
			number_of_players += 1
	print(find_node("Scenes").get_child(0))
	
	if find_node("Scenes").find_node("PickingScreen") != null:
		find_node("PickingScreen").get_players()
	print("Number of players: ", number_of_players)

func _process(delta):
	if Input.is_action_just_pressed("menu_select"):
		for child in $Scenes.get_children():
			if child.name == "TitleScreen":
				if child.get_node("PlayButton").is_disabled() == true:
					change_scene(Picking_Screen)
				elif child.get_node("PlayButton").is_disabled() == false:
					print(child.get_node("PlayButton").pressed)
					child._on_PlayButton_pressed()

func change_scene(next_scene):
	var add_hud = false
	for scene in $Scenes.get_children():
		print(scene.name, " was removed")
		scene.queue_free()
	
	match next_scene:
		"title_screen":
			next_scene = Title_Screen
		"picking_screen":
			next_scene = Picking_Screen
		"game_screen":
			next_scene = Play_Screen
	
	var i = next_scene.instance()
	$Scenes.add_child(i)