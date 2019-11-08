extends Node2D

var speed = 4

func _ready():
	$AnimationPlayer.current_animation = "idle"

func _process(delta):
	if Input.is_action_just_pressed("ui_right"):
		$Particles2D.emitting = true
		$AnimationPlayer.current_animation = "walking"
	if Input.is_action_pressed("ui_right"):
		position.x += speed
	if Input.is_action_just_released("ui_right"):
		$Particles2D.emitting = false
		$AnimationPlayer.current_animation = "idle"

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
