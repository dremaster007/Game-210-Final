extends Spatial

onready var characters = [$MainBuilding/Character1, $MainBuilding/Character2, $MainBuilding/Character3,
						$MainBuilding/Character4, $MainBuilding/Character5, $MainBuilding/Character6,
						$MainBuilding/Character7, $MainBuilding/Character8]

var char_selected = null
var selected_num = 0

var first_row_min = 0
var first_row_max = 3
var second_row_min = 4
var second_row_max = 7

func _ready():
	cycle_characters()

func _process(delta):
	get_input()

func get_input():
	#----------------------------------------------------------
	# GETTING THE NUMBER OF THE CHARACTER THAT WILL BE SELECTED
	if Input.is_action_just_pressed("left_1"):
		# We are doing some basic math to make sure that we can scroll off screen and not
		# go down to the next row. We go back to the start of the row we are on.
		selected_num -= 1
		if selected_num == first_row_min - 1:
			selected_num = first_row_max
		elif selected_num == second_row_min - 1:
			selected_num = second_row_max
		cycle_characters()
	
	elif Input.is_action_just_pressed("right_1"):
		# Same reason for when we press left
		selected_num += 1
		if selected_num == first_row_max + 1:
			selected_num = first_row_min
		elif selected_num == second_row_max + 1:
			selected_num = second_row_min
		cycle_characters()
	
	# Up and Down are different because we can save lines of code by putting
	# the overlapping code in a new if statement. This is a better practice.
	elif Input.is_action_just_pressed("up_1"):
		selected_num -= 4
	
	elif Input.is_action_just_pressed("down_1"):
		selected_num += 4
	
	if Input.is_action_just_pressed("up_1") or Input.is_action_just_pressed("down_1"):
		if selected_num < first_row_min:
			selected_num += 8
		elif selected_num > second_row_max:
			selected_num -= 8
		cycle_characters()
	#----------------------------------------------------------

func cycle_characters():
	# Set the character selected to the number in the array
	char_selected = characters[selected_num]
	# Set all other sprites in the array to look like they are unselected
	for i in characters:
		i.opacity = 1
	# Set the character select to show that they are selected
	char_selected.opacity = 0.5

