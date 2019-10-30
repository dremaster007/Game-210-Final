extends Node2D

export (PackedScene) var Paint

func _process(delta):
	get_input()

func get_input():
	if Input.is_action_just_pressed("left_click"):
		place_sprite("red", get_global_mouse_position())
	elif Input.is_action_just_pressed("right_click"):
		place_sprite("blue", get_global_mouse_position())

func place_sprite(color, mouse_pos):
	var color_vals
	match color:
		"red":
			color_vals = Color(1,0,0,1)
			var p = Paint.instance()
			p.start(color_vals)
			p.position = mouse_pos
			get_node("RedContainer").add_child(p)
		"blue":
			color_vals = Color(0,0,1,1)
			var p = Paint.instance()
			p.start(color_vals)
			p.position = mouse_pos
			get_node("BlueContainer").add_child(p)