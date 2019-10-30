extends Area

func _on_OneWayPlatform_area_entered(area):
	if area.is_in_group("player"):
		var player = area.get_parent()
		if player.platform_fall == true:
			$StaticBody/CollisionShape.disabled = true
		elif player.velocity.y > player.EPSILON:
			$StaticBody/CollisionShape.disabled = true
		elif player.velocity.y <= player.EPSILON:
			$StaticBody/CollisionShape.disabled = false
		else:
			$StaticBody/CollisionShape.disabled = false
