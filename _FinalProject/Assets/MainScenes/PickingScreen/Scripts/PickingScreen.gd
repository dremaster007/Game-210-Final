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

var players_ready = 0

var Global = null

func _ready():
	Global = find_parent("Global")
	get_players()

func _process(delta):
	if players_ready == Global.number_of_players:
		Global.change_scene("game_screen")

func get_players():
	for player in $PlayerCounter.get_children():
		player.queue_free()
	
	for sprite in $SelectionSprites.get_children():
		sprite.hide()
	
	for player_num in Global.number_of_players:
		var i = PickingScreenPlayer.instance()
		i.player_number = player_num + 1
		$PlayerCounter.add_child(i)
		get_node("SelectionSprites/Player%s" % i.player_number).show()
		cycle_characters(i.player_number, selected_number)

func select_character(player_number, select_num):
	match player_number:
		1:
			Global.player_picks["player_1"] = select_num
		2:
			Global.player_picks["player_2"] = select_num
		3:
			Global.player_picks["player_3"] = select_num
		4:
			Global.player_picks["player_4"] = select_num

func cycle_characters(player_number, selected_num):
	match player_number:
		1:
			# Set the character selected to the number in the array
			char_selected_1 = characters[selected_num]
			$SelectionSpriteTweens/Tween.interpolate_property($SelectionSprites/Player1, "translation", $SelectionSprites/Player1.translation, char_selected_1.translation + Vector3(0, 0, -0.65), 0.1,Tween.TRANS_BOUNCE,Tween.EASE_IN_OUT)                                       
			$SelectionSpriteTweens/Tween.start()
		2:
			char_selected_2 = characters[selected_num]
			$SelectionSpriteTweens/Tween.interpolate_property($SelectionSprites/Player2, "translation", $SelectionSprites/Player2.translation, char_selected_2.translation + Vector3(0, 0, -0.65), 0.1,Tween.TRANS_BOUNCE,Tween.EASE_IN_OUT)                                       
			$SelectionSpriteTweens/Tween.start()
		3:
			char_selected_3 = characters[selected_num]
			$SelectionSpriteTweens/Tween.interpolate_property($SelectionSprites/Player3, "translation", $SelectionSprites/Player3.translation, char_selected_3.translation + Vector3(0, 0, -0.65), 0.1,Tween.TRANS_BOUNCE,Tween.EASE_IN_OUT)                                       
			$SelectionSpriteTweens/Tween.start()
		4:
			char_selected_4 = characters[selected_num]
			$SelectionSpriteTweens/Tween.interpolate_property($SelectionSprites/Player4, "translation", $SelectionSprites/Player4.translation, char_selected_4.translation + Vector3(0, 0, -0.65), 0.1,Tween.TRANS_BOUNCE,Tween.EASE_IN_OUT)                                       
			$SelectionSpriteTweens/Tween.start()
