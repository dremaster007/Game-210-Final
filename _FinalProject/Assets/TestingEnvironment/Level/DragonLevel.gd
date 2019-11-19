extends Node2D

var number_of_players = 0

func _ready():
	var x = $Player_Container.get_child_count()
	var y = $Player_Container.get_children()
	for y in x:
		var z = $Player_Container.get_child(y)
		number_of_players += 1
		z.player_number = number_of_players
		z.load_textures()