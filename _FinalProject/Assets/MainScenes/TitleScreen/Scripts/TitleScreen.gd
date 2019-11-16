extends Node2D

var Global = null

func _ready():
	if get_parent().get_parent() != null:
		Global = get_parent().get_parent()

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
	Global.change_scene("picking_screen")