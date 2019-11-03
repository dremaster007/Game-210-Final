extends Spatial

onready var characters = [$MainBuilding/Character1, $MainBuilding/Character2, $MainBuilding/Character3,
						$MainBuilding/Character4, $MainBuilding/Character5, $MainBuilding/Character6,
						$MainBuilding/Character7, $MainBuilding/Character8]

var char_selected = null
var selected_num = 0

func _ready():
	char_selected = characters[selected_num]
	cycle_characters()

func _process(delta):
	get_input()

func get_input():
	if Input.is_action_just_pressed("left_1"):
		selected_num -= 1
		if selected_num == -1:
			selected_num = 3
		elif selected_num == 3:
			selected_num = 7
		cycle_characters()
	elif Input.is_action_just_pressed("right_1"):
		selected_num += 1
		if selected_num == 4:
			selected_num = 0
		elif selected_num == 8:
			selected_num = 4
		cycle_characters()
	elif Input.is_action_just_pressed("up_1"):
		selected_num -= 4
	elif Input.is_action_just_pressed("down_1"):
		selected_num += 4
	if Input.is_action_just_pressed("up_1") or Input.is_action_just_pressed("down_1"):
		if selected_num < 0:
			selected_num += 8
		elif selected_num > 7:
			selected_num -= 8
		cycle_characters()


func cycle_characters():
	char_selected = characters[selected_num]
	for i in characters:
		i.opacity = 1
	char_selected.opacity = 0.5

