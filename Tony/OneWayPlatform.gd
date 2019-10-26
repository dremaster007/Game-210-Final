extends Area

func _on_OneWayPlatform_body_entered(body):
	if body.is_in_group("player"):
		print(body.platform_fall)
		if body.platform_fall == true:
			$StaticBody/CollisionShape.disabled = true
		elif body.velocity.y > 0:
			$StaticBody/CollisionShape.disabled = true
		elif body.velocity.y <= 0:
			$StaticBody/CollisionShape.disabled = false
		else:
			$StaticBody/CollisionShape.disabled = false
