extends Node2D

func play_particle():
	$DustParticles.emitting = true
	yield(get_tree().create_timer(0.2), "timeout")
	$DustParticles.emitting = false
