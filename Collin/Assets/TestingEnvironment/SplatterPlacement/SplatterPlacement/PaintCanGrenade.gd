extends RigidBody2D

func _ready():
	pass 


func explode():
	#Adds paint splatter within the ExplosionArea 
	find_parent("DragonLevel").place_paint("paintcolor", global_position)


func _on_ExplosionTimer_timeout():
	explode()
	#Calls explode function when timer runs out.
