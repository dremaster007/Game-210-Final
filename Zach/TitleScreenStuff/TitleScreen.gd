extends Node2D

export (String, FILE) var picking_scene

func _ready():
	OS.window_fullscreen = true

func play_animation(anim):
	if anim == "to_picking_scene":
		$TitleTransition.play_transition()

func change_scene(new_scene):
	get_tree().change_scene(new_scene)

func _on_PlayButton_pressed():
	play_animation("to_picking_scene")

func _on_TitleTransition_transition_finished():
	change_scene(picking_scene)
