extends Node2D

func _ready():
	yield(get_tree().create_timer(2), "timeout")
	flip_character()
	yield(get_tree().create_timer(2), "timeout")
	flip_character()

func flip_character():
	for node in get_children():
		if node is Sprite:
			node.flip_h = !node.flip_h
		for node2 in node.get_children():
			if node2 is Sprite:
				node2.flip_h = !node2.flip_h
			for node3 in node2.get_children():
				if node3 is Sprite:
					node3.flip_h = !node3.flip_h
				for node4 in node3.get_children():
					if node4 is Sprite:
						node4.flip_h = !node4.flip_h
