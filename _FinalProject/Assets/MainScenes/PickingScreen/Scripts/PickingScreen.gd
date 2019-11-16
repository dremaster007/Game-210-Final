extends Spatial

onready var characters = [$MainBuilding/CharacterHolder/Character1,
						$MainBuilding/CharacterHolder/Character2,
						$MainBuilding/CharacterHolder/Character3,
						$MainBuilding/CharacterHolder/Character4,
						$MainBuilding/CharacterHolder/Character5,
						$MainBuilding/CharacterHolder/Character6,
						$MainBuilding/CharacterHolder/Character7,
						$MainBuilding/CharacterHolder/Character8]

export (PackedScene) var PickingScreenPlayer


var char_selected_1 = null
var char_selected_2 = null
var char_selected_3 = null
var char_selected_4 = null

var selected_number = 0

var first_row_min = 0
var first_row_max = 3
var second_row_min = 4
var second_row_max = 7

var Global = null

func _ready():
	Global = find_parent("Global")
	get_players()

func get_players():
	for player in $PlayerCounter.get_children():
		player.queue_free()
	
	for player_num in Global.number_of_players:
		var i = PickingScreenPlayer.instance()
		i.player_number = player_num + 1
		$PlayerCounter.add_child(i)
		cycle_characters(i.player_number, selected_number)

func cycle_characters(player_number, selected_num):
	#for i in characters:
		#i.get_surface_material(0).set_albedo(Color(1,1,1,1))
	
	match player_number:
		1:
			# Set the character selected to the number in the array
			char_selected_1 = characters[selected_num]
			$SelectionSprites/Player1.translation.x = char_selected_1.translation.x
			$SelectionSprites/Player1.translation.y = char_selected_1.translation.y
		2:
			char_selected_2 = characters[selected_num]
			$SelectionSprites/Player2.translation.x = char_selected_2.translation.x
			$SelectionSprites/Player2.translation.y = char_selected_2.translation.y
		3:
			char_selected_3 = characters[selected_num]
			$SelectionSprites/Player3.translation.x = char_selected_3.translation.x
			$SelectionSprites/Player3.translation.y = char_selected_3.translation.y
		4:
			char_selected_4 = characters[selected_num]
			$SelectionSprites/Player4.translation.x = char_selected_4.translation.x
			$SelectionSprites/Player4.translation.y = char_selected_4.translation.y
