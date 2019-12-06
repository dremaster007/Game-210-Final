extends Node2D

func play_particle():
	$DustParticles.emitting = true
	yield(get_tree().create_timer(0.2), "timeout")
	$DustParticles.emitting = false

func play_firecracker_explosion():
	$firecrackerExplosion.emitting = true
	yield(get_tree().create_timer(0.5), "timeout")
	$firecrackerExplosion.emitting = false


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "victory_start":
		$AnimationPlayer.play("victory_loop")
#	if anim_name == "victory_loop" and Global.can_restart:
#		$AnimationPlayer.play("victory_end")
