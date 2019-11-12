extends CanvasLayer

export (String, FILE) var picking_scene

func _ready():
	OS.window_fullscreen = true
	
	$PlayButton.connect("pressed", self, "play_animation", ["play"])

func play_animation(animation):
	match animation:
		"play":
			$AnimationPlayer.play("change_scene")

func change_scene(new_scene):
	get_tree().change_scene(new_scene)
	#print(new_scene)