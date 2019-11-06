extends Node2D

export (PackedScene) var Paint

var red_score = 0
var blue_score = 0

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
			p.start(color_vals, "red")
			p.position = mouse_pos
			get_node("Container").add_child(p)
		"blue":
			color_vals = Color(0,0,1,1)
			var p = Paint.instance()
			p.start(color_vals, "blue")
			p.position = mouse_pos
			get_node("Container").add_child(p)
	count_score()

func count_score():
	var red_counter = 0
	var blue_counter = 0
	if $Container.get_child_count() == 0:
		return
	for node in $Container.get_children():
		if node.type == "red":
			red_counter += node.score_value
		elif node.type == "blue":
			blue_counter += node.score_value
		print(red_counter)
	red_score = red_counter
	blue_score = blue_counter
	print("The red score is: ", red_score)
	print("The blue score is: ", blue_score)