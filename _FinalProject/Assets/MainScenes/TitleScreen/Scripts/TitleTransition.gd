extends Node2D

signal transition_finished # when the spray painting animation is finished

# This function will call play on the animation player
func play_transition():
	$AnimationPlayer.play("to_picking_screen")

# This function is called when the animation player finishes
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "to_picking_screen":
		emit_signal("transition_finished")
