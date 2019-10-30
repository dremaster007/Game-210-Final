extends Node2D

var splatter_textures = [load("res://SpriteTesting/SpriteAssets/splatter_1.png"), load("res://SpriteTesting/SpriteAssets/splatter_2.png"), load("res://SpriteTesting/SpriteAssets/splatter_3.png"), load("res://SpriteTesting/SpriteAssets/splatter_4.png")]

var is_placed = false

func _ready():
	$SpriteHolder/Sprite1.texture = splatter_textures[randi() % 4]
	$SpriteHolder/Sprite2.texture = splatter_textures[randi() % 4]
	$SpriteHolder/Sprite3.texture = splatter_textures[randi() % 4]
	$SpriteHolder/Sprite4.texture = splatter_textures[randi() % 4]

func start(color_val):
	for node in $SpriteHolder.get_children():
		node.modulate = color_val

func _on_TLCheck_area_shape_entered(area_id, area, area_shape, self_shape):
	if area.get_parent().is_placed:
		if area_shape == 0:
			area.get_parent().get_node("SpriteHolder/Sprite1").queue_free()
			area.get_parent().get_node("Check/Col1").queue_free()
		elif area_shape == 1:
			area.get_parent().get_node("SpriteHolder/Sprite2").queue_free()
			area.get_parent().get_node("Check/Col2").queue_free()
		elif area_shape == 2:
			area.get_parent().get_node("SpriteHolder/Sprite3").queue_free()
			area.get_parent().get_node("Check/Col3").queue_free()
		elif area_shape == 3:
			area.get_parent().get_node("SpriteHolder/Sprite4").queue_free()
			area.get_parent().get_node("Check/Col4").queue_free()
	yield(get_tree().create_timer(0.3), "timeout")
	is_placed = true