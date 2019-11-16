extends Node

# When the character plugs in a new controller, we need to make sure they can select a
# character independently of anyone else

var char_selected_1 = null
var char_selected_2 = null
var char_selected_3 = null
var char_selected_4 = null

var selected_num = 0

var selected_num_1 = 0
var selected_num_2 = 0
var selected_num_3 = 0
var selected_num_4 = 0

var first_row_min = 0
var first_row_max = 3
var second_row_min = 4
var second_row_max = 7

var player_number = 0

var locked_in = false

var Global = null
var Picking_Screen = null

func _ready():
	Global = find_parent("Global")
	Picking_Screen = find_parent("PickingScreen")

func _process(delta):
	get_input()

func get_input():
	var left = Input.is_action_just_pressed("left_%s" % player_number)
	var right = Input.is_action_just_pressed("right_%s" % player_number)
	var up = Input.is_action_just_pressed("up_%s" % player_number)
	var down = Input.is_action_just_pressed("down_%s" % player_number)
	var select = Input.is_action_just_pressed("select_%s" % player_number)
	var back = Input.is_action_just_pressed("back_%s" % player_number)
	
	if locked_in == false:
		#----------------------------------------------------------
		# GETTING THE NUMBER OF THE CHARACTER THAT WILL BE SELECTED
		if left:
			# We are doing some basic math to make sure that we can scroll off screen and not
			# go down to the next row. We go back to the start of the row we are on.
			selected_num -= 1
			if selected_num == first_row_min - 1:
				selected_num = first_row_max
			elif selected_num == second_row_min - 1:
				selected_num = second_row_max
			Picking_Screen.cycle_characters(player_number, selected_num)
		
		elif right:
			# Same reason for when we press left
			selected_num += 1
			if selected_num == first_row_max + 1:
				selected_num = first_row_min
			elif selected_num == second_row_max + 1:
				selected_num = second_row_min
			Picking_Screen.cycle_characters(player_number, selected_num)
		
		# Up and Down are different because we can save lines of code by putting
		# the overlapping code in a new if statement. This is a better practice.
		elif up:
			selected_num -= 4
		
		elif down:
			selected_num += 4
		
		if up or down:
			if selected_num < first_row_min:
				selected_num += 8
			elif selected_num > second_row_max:
				selected_num -= 8
			Picking_Screen.cycle_characters(player_number, selected_num)
		
		if select:
			locked_in = true
		#----------------------------------------------------------
	if back:
		if locked_in == true:
			locked_in = false
		elif locked_in == false:
			Global.change_scene("title_screen")
	