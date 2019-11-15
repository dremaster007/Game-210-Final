extends Node2D

export (String, FILE) var picking_scene # This is the scene that we pick our characters from

# This gets our window in fullscreen mode
func _ready():
	OS.window_fullscreen = true

# This will play whatever animation you send it
func play_animation(anim):
	if anim == "to_picking_scene":
		$TitleTransition.play_transition()

# This will change your current scene into the new one
func change_scene(new_scene):
	get_tree().change_scene(new_scene)

# This is called when the play button is pressed
func _on_PlayButton_pressed():
	$PlayButtonSound.play() # Play the spray can noise
	$PlayButton.disabled = true # Disabled the button
	yield(get_tree().create_timer(1), "timeout")
	play_animation("to_picking_scene")

func _on_TitleTransition_transition_finished():
	change_scene(picking_scene)