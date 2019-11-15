extends Node2D

signal transition_finished

func play_transition():
	$AnimationPlayer.play("to_picking_screen")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "to_picking_screen":
		emit_signal("transition_finished")
