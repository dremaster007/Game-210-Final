extends Node2D

# this playes the dust particle (when jumping, and attacking)
func play_particle():
	$DustParticles.emitting = true
	yield(get_tree().create_timer(0.2), "timeout")
	$DustParticles.emitting = false

