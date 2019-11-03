extends Node2D

# textures of the splatter
var splatter_textures = [load("res://SpriteTesting/SpriteAssets/splatter_1.png"), load("res://SpriteTesting/SpriteAssets/splatter_2.png"), 
		load("res://SpriteTesting/SpriteAssets/splatter_3.png"), load("res://SpriteTesting/SpriteAssets/splatter_4.png")]

# is the paint on the background
var is_placed = false
var type
#var going_to_qf = false

# set all of the textures
func _ready():
	$SpriteHolder/Sprite1.texture = splatter_textures[randi() % 4]
	$SpriteHolder/Sprite2.texture = splatter_textures[randi() % 4]
	$SpriteHolder/Sprite3.texture = splatter_textures[randi() % 4]
	$SpriteHolder/Sprite4.texture = splatter_textures[randi() % 4]

# just set the color value
func start(color_val, color_type):
	for node in $SpriteHolder.get_children():
		node.modulate = color_val
		type = color_type

func _process(delta):
	if Input.is_action_just_pressed("ui_left"):
		for node in $SpriteHolder.get_children():
			node.hide()
	if Input.is_action_just_pressed("ui_right"):
		for node in $SpriteHolder.get_children():
			node.show()

func set_placed():
	is_placed = true

func _on_TLCheck_area_shape_entered(area_id, area, area_shape, self_shape):
	if area.get_parent().is_placed:
		if area_shape == 0:
			if area.get_parent().get_node("SpriteHolder/Sprite1") == null:
				return
			area.get_parent().get_node("SpriteHolder/Sprite1").queue_free()
			area.get_parent().get_node("Check/Col1").queue_free()
		if area_shape == 1:
			if area.get_parent().get_node("SpriteHolder/Sprite2") == null:
				return
			area.get_parent().get_node("SpriteHolder/Sprite2").queue_free()
			area.get_parent().get_node("Check/Col2").queue_free()
		if area_shape == 2:
			if area.get_parent().get_node("SpriteHolder/Sprite3") == null:
				return
			area.get_parent().get_node("SpriteHolder/Sprite3").queue_free()
			area.get_parent().get_node("Check/Col3").queue_free()
		if area_shape == 3:
			if area.get_parent().get_node("SpriteHolder/Sprite4") == null:
				return
			area.get_parent().get_node("SpriteHolder/Sprite4").queue_free()
			area.get_parent().get_node("Check/Col4").queue_free()

func _on_PlaceTimer_timeout():
	set_placed()
