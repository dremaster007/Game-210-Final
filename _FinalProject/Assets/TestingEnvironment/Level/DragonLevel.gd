extends Node2D

export (PackedScene) var Player

var Global = null

func _ready():
	Global = find_parent("Global")
	# For each number of players, we have to actually spawn in a player character 
	for number in Global.number_of_players:
		var i = Player.instance()
		# We set their number starting at one and going up each time until the number
		# of player's has been reached
		i.player_number = number + 1
		if i.player_number == 2 or i.player_number == 4:
			i.facing_dir = "left"
		i.position = get_node("SpawnPoints/Spawn%s" %(number + 1)).position
		# We load in the player textures above their head
		i.load_textures()
		$Player_Container.add_child(i)
	# Then we allow the camera to start tracking them.
	$DynamicCamera.cam_start()
	start()

func start():
	for child in $Player_Container.get_children():
		child.can_input = false
	$HUD.countdown()
	yield(get_tree().create_timer(4),"timeout")
	for child in $Player_Container.get_children():
		child.can_input = true