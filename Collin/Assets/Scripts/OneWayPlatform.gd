extends Area2D

func _on_OneWayPlatform_area_entered(area):
	if area.is_in_group("player"):
		var player = area.get_parent()
		if player.platform_fall == true:
			$StaticBody2D/CollisionShape2D.disabled = true
		elif player.velocity.y > player.EPSILON:
			$StaticBody2D/CollisionShape2D.disabled = true
		elif player.velocity.y <= player.EPSILON:
			$StaticBody2D/CollisionShape2D.disabled = false
		else:
			$StaticBody2D/CollisionShape2D.disabled = false
