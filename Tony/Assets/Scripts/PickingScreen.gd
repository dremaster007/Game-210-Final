extends Spatial

onready var characters = [$MainBuilding/CharacterHolder/Character1,
						$MainBuilding/CharacterHolder/Character2,
						$MainBuilding/CharacterHolder/Character3,
						$MainBuilding/CharacterHolder/Character4,
						$MainBuilding/CharacterHolder/Character5,
						$MainBuilding/CharacterHolder/Character6,
						$MainBuilding/CharacterHolder/Character7,
						$MainBuilding/CharacterHolder/Character8]

var char_selected = null
var selected_num_1 = 0
var selected_num_2 = 0
var selected_num_3 = 0
var selected_num_4 = 0

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
		selected_num_1 -= 1
		if selected_num_1 == first_row_min - 1:
			selected_num_1 = first_row_max
		elif selected_num_1 == second_row_min - 1:
			selected_num_1 = second_row_max
		cycle_characters()
	
	elif Input.is_action_just_pressed("right_1"):
		# Same reason for when we press left
		selected_num_1 += 1
		if selected_num_1 == first_row_max + 1:
			selected_num_1 = first_row_min
		elif selected_num_1 == second_row_max + 1:
			selected_num_1 = second_row_min
		cycle_characters()
	
	# Up and Down are different because we can save lines of code by putting
	# the overlapping code in a new if statement. This is a better practice.
	elif Input.is_action_just_pressed("up_1"):
		selected_num_1 -= 4
	
	elif Input.is_action_just_pressed("down_1"):
		selected_num_1 += 4
	
	if Input.is_action_just_pressed("up_1") or Input.is_action_just_pressed("down_1"):
		if selected_num_1 < first_row_min:
			selected_num_1 += 8
		elif selected_num_1 > second_row_max:
			selected_num_1 -= 8
		cycle_characters()
	#----------------------------------------------------------

func cycle_characters():
	# Set the character selected to the number in the array
	char_selected = characters[selected_num_1]
	# Set all other sprites in the array to look like they are unselected
	for i in characters:
		#print(i.get_surface_material(0))
		i.get_surface_material(0).set_albedo(Color(1,1,1,1))
	#print(char_selected)
	
	char_selected.get_surface_material(0).set_albedo(Color(0.5,0.5,0.5))
	# Set the character select to show that they are selected
	#char_selected.opacity = 0.5

