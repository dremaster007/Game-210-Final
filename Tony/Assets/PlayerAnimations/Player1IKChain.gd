extends Node2D

var speed = 4

func _ready():
	$AnimationPlayer.current_animation = "idle"

func play_particle():
	$DustParticles.emitting = true
	yield(get_tree().create_timer(0.2), "timeout")
	$DustParticles.emitting = false

func flip_character():
	for node in get_children():
		if node is Sprite:
			node.position.x = sign(node.position.x)
			node.flip_h = !node.flip_h
		for node2 in node.get_children():
			if node2 is Sprite:
				node2.position.x = sign(node2.position.x)
				node2.flip_h = !node2.flip_h
			for node3 in node2.get_children():
				if node3 is Sprite:
					node3.position.x = sign(node3.position.x)
					node3.flip_h = !node3.flip_h
				for node4 in node3.get_children():
					if node4 is Sprite:
						node4.position.x = sign(node4.position.x)
						node4.flip_h = !node4.flip_h
