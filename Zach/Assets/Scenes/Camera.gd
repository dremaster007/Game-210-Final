extends Camera

var characters_on_screen = []
var character_count

func _ready():
	for node in get_parent().get_children():
		if node.is_in_group("player"):
			characters_on_screen.append(node)
	character_count = characters_on_screen.size()

func _process(delta):
	process_character_positions()

func process_character_positions():
	var char1 = null
	var char2 = null
	var char3 = null
	var char4 = null
	var char1_transl = null
	var char2_transl = null
	var char3_transl = null
	var char4_transl = null
	match character_count:
		1:
			char1 = characters_on_screen[0]
			char1_transl = char1.translation
		2:
			char2 = characters_on_screen[1]
			char2_transl = char2.translation
		3:
			char3 = characters_on_screen[2]
			char3_transl = char3.translation
			print("third")
		4:
			char4 = characters_on_screen[3]
			char4_transl = char4.translation
			
	print(char1_transl)
	print(char2_transl)