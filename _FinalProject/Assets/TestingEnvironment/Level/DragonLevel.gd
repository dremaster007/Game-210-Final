extends Node2D

export (PackedScene) var Player
export (PackedScene) var Paint

var player_color = ["red","blue","green","yellow"]

var red_score
var blue_score
var green_score
var yellow_score

var red_ult
var blue_ult
var green_ult
var yellow_ult

var Global = null

var dynamic_camera_start = false

func _ready():
	Global = find_parent("Global")
	# For each number of players, we have to actually spawn in a player character 
	for number in Global.number_of_players:
		var i = Player.instance()
		# We set their number starting at one and going up each time until the number
		# of player's has been reached
		i.player_number = number + 1
		i.player_color = player_color[number]
		#HERE
		if i.player_number == 2 or i.player_number == 4:
			i.facing_dir = "left"
		i.position = get_node("SpawnPoints/Spawn%s" %(number + 1)).position
		# We load in the player textures above their head
		i.load_textures(Global.player_picks["player_%s" % i.player_number])
		$Player_Container.add_child(i)
	# Then we allow the camera to start tracking them.
	$CameraTween.interpolate_property($DynamicCamera, "position", Vector2(0, -325), Vector2(0, 0), 3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$CameraTween.interpolate_property($DynamicCamera, "zoom", Vector2(1.3, 1.3), Vector2(0.5, 0.5), 3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$CameraTween.start()
	start()

func start():
	for child in $Player_Container.get_children():
		child.set_process(true)
		child.can_input = false
	$HUD.countdown()
	yield(get_tree().create_timer(4),"timeout")
	$DynamicCamera.cam_start()
	for child in $Player_Container.get_children():
		child.can_input = true

func place_paint(color, pos):
	var color_vals
	match color:
		"red":
			color_vals = Color(1,0,0,1)
			var p = Paint.instance()
			p.start(color_vals, "red")
			p.position = pos
			find_node("PaintContainer").add_child(p)
		"blue":
			color_vals = Color(0,0,1,1)
			var p = Paint.instance()
			p.start(color_vals, "blue")
			p.position = pos
			find_node("PaintContainer").add_child(p)
		"green":
			color_vals = Color(0,1,0,1)
			var p = Paint.instance()
			p.start(color_vals, "green")
			p.position = pos
			find_node("PaintContainer").add_child(p)
		"yellow":
			color_vals = Color(0,1,1,1)
			var p = Paint.instance()
			p.start(color_vals, "yellow")
			p.position = pos
			find_node("PaintContainer").add_child(p)
	count_score()

func update_ult(color, value):
	$HUD.update_hud("ultimate", color, value)

func count_score():
	var red_counter = 0
	var blue_counter = 0
	var green_counter = 0
	var yellow_counter = 0
	
	var color = ""
	if find_node("PaintContainer").get_child_count() == 0:
		return
	for node in find_node("PaintContainer").get_children():
		match node.type:
			"red":
				red_counter += node.score_value
			"blue":
				blue_counter += node.score_value
			"green":
				green_counter += node.score_value
			"yellow":
				yellow_counter += node.score_value
	red_score = red_counter
	blue_score = blue_counter
	green_score = green_counter
	yellow_score = yellow_counter
	
	$HUD.max_paint_value = red_score + blue_score + green_score + yellow_score
	
	$HUD.update_hud("paint", "red", red_score)
	$HUD.update_hud("paint", "blue", blue_score)
	$HUD.update_hud("paint", "green", green_score)
	$HUD.update_hud("paint", "yellow", yellow_score)
	
	#print("The red score is: ", red_score)
	#print("The blue score is: ", blue_score)
	#print("The green score is: ", green_score)
	#print("The yellow score is: ", yellow_score)

func game_over():
	for child in $Player_Container.get_children():
		child.can_input = false
		child.velocity = Vector2()
		child.set_process(false)
	Global.player_score["player_1"] = red_score
	Global.player_score["player_2"] = blue_score
	Global.player_score["player_3"] = green_score
	Global.player_score["player_4"] = yellow_score
	
	print(Global.player_score["player_1"])
	print(Global.player_score["player_2"])
	print(Global.player_score["player_3"])
	print(Global.player_score["player_4"])

func _on_CameraTween_tween_all_completed():
	dynamic_camera_start = true
