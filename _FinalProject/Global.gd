extends Node

export (PackedScene) var Title_Screen
export (PackedScene) var Picking_Screen
export (PackedScene) var Play_Screen

func _ready():
	OS.window_fullscreen = true
	change_scene(Title_Screen)

func _process(delta):
	if Input.is_action_just_pressed("jump_1"):
		change_scene(Picking_Screen)

func change_scene(next_scene):
	for scene in $Scenes.get_children():
		print(scene.name, " was removed")
		scene.queue_free()
	
	match next_scene:
		"title_screen":
			next_scene = Title_Screen
		"picking_screen":
			next_scene = Picking_Screen
		"game_screen":
			next_scene = Play_Screen
	
	var i = next_scene.instance()
	$Scenes.add_child(i)